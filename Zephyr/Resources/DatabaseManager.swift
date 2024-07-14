//
//  DatabaseManager.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import FirebaseFirestore

public class DatabaseManager{
    static let shared = DatabaseManager()
    let db = Firestore.firestore()
    
    // MARK: - Public
    public func canCreateNewUser(with email: String, userName: String, completion: @escaping(Bool, Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var emailExists: Bool = false
        var userNameExists: Bool = false
        var emailError: Error? = nil
        var userNameError: Error? = nil
        
        dispatchGroup.enter()
        getEmail(for: userName) { foundEmail in
            if let _ = foundEmail {
                print(foundEmail!)
                emailExists = true
                emailError = NSError(domain: Constants.Errors.userNameAlreadyExists, code: Constants.ErrorCodes.userNameAlreadyExists, userInfo: nil)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        getUserName(for: email) { foundUserName in
            if let _ = foundUserName {
                userNameExists = true
                userNameError = NSError(domain: Constants.Errors.emailAlreadyInUse, code: Constants.ErrorCodes.emailAlreadyInUse, userInfo: nil)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if emailExists {
                completion(false, emailError)
            } else if userNameExists {
                completion(false, userNameError)
            } else {
                completion(true, nil)
            }
        }
    }

    public func insertNewUser(with email: String, userName: String, completion: @escaping (Bool) -> Void){
        db.collection(Constants.FireStore.users).addDocument(data: [
            Constants.FireStore.userName: userName,
            Constants.FireStore.email: email
        ]){ error in
            if error == nil{
                completion(true)
                return
            } else{
                completion(false)
                return
            }
        }
    }
    func getEmail(for username: String, completion: @escaping (String?) -> Void) {
        let usersCollection = db.collection("users")
        usersCollection.whereField("userName", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let _ = error {
                completion(nil)
                return
            } else if let document = querySnapshot?.documents.first {
                let email = document.data()["email"] as? String
                completion(email)
                return
            } else {
                completion(nil)
                return
            }
        }
    }
    func getUserName(for email: String, completion: @escaping (String?)-> Void) {
        let usersCollection = db.collection("users")
        usersCollection.whereField("email", isEqualTo: email).getDocuments{
            (querySnapshot, error) in
            if let _ = error{
                completion(nil)
                return
            } else if let document = querySnapshot?.documents.first{
                let userName = document.data()["userName"] as? String
                completion(userName)
                return
            } else{
                completion(nil)
                return
            }
        }
    }
    func savePost(_ post: UserPost, completion: @escaping (Bool) -> Void) {
        let postData: [String: Any] = [
            "identifier": post.identifier,
            "postType": post.postType == .photo ? "photo" : "video",
            "thumbnailImage": post.thumbnailImage.absoluteString,
            "postURL": post.postURL.absoluteString,
            "caption": post.caption ?? "",
            "createDate": post.createDate,
            "taggedUsers": post.taggedUsers,
            "ownerUserName": post.owner.userName,
            "likesPath": "posts/\(post.identifier)/likes",
            "commentsPath": "posts/\(post.identifier)/comments"
        ]
        
        db.collection("posts").document(post.identifier).setData(postData) { error in
            if let error = error {
                print("Error saving post: \(error.localizedDescription)")
                completion(false)
            } else {
                self.incrementUserPostsCount(userName: post.owner.userName) { success in
                    completion(success)
                }
            }
        }
    }
        
    private func incrementUserPostsCount(userName: String, completion: @escaping (Bool) -> Void) {
        let usersCollection = db.collection("users")
        usersCollection.whereField("userName", isEqualTo: userName).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let document = querySnapshot?.documents.first else {
                print("User not found.")
                completion(false)
                return
            }
            let userDocRef = document.reference
            
            userDocRef.updateData([
                "counts.posts": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error incrementing user posts count: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    func addLike(to postID: String, from user: UserModel, completion: @escaping (Bool) -> Void) {
        let likeData: [String: Any] = [
            "userName": user.userName,
            "postIdentifier": postID
        ]
        
        db.collection("posts").document(postID).collection("likes").addDocument(data: likeData) { error in
            completion(error == nil)
        }
    }

    func addComment(to postID: String, comment: PostComment, completion: @escaping (Bool) -> Void) {
        let commentData: [String: Any] = [
            "identifier": comment.identifier,
            "user": [
                "userName": comment.user.userName,
                "profilePicture": comment.user.profilePicture.absoluteString,
                "bio": comment.user.bio,
                "firstName": comment.user.name.first,
                "lastName": comment.user.name.last,
                "birthDate": comment.user.birthDate,
                "gender": comment.user.gender.rawValue,
                "counts": [
                    "posts": comment.user.counts.posts,
                    "followers": comment.user.counts.followers,
                    "following": comment.user.counts.following
                ],
                "joinDate": comment.user.joinDate,
                "followers": comment.user.followers,
                "following": comment.user.following
            ],
            "text": comment.text,
            "createdDate": comment.createdDate,
            "likes": comment.likes.map { $0.userName }
        ]
        
        db.collection("posts").document(postID).collection("comments").addDocument(data: commentData) { error in
            completion(error == nil)
        }
    }
    func fetchUserData(for userName: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        fetchUserDocumentID(by: userName) { documentID in
            guard let documentID = documentID else {
                completion(.failure(NSError(domain: "UserNotFound", code: 1, userInfo: nil)))
                return
            }
            
            let userDocRef = self.db.collection("users").document(documentID)
            userDocRef.getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = document?.data(), let userModel = UserModel(dictionary: data) else {
                    completion(.failure(NSError(domain: "UserDataError", code: 0, userInfo: nil)))
                    return
                }
                
                completion(.success(userModel))
            }
        }
    }
    func fetchUserDocumentID(by userName: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("userName", isEqualTo: userName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user found with the username \(userName)")
                completion(nil)
                return
            }
            let documentID = documents[0].documentID
            completion(documentID)
        }
    }
}
