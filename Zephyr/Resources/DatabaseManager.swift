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
            Constants.FireStore.email: email,
            Constants.FireStore.bio: Constants.empty,
            Constants.FireStore.posts: 0,
            Constants.FireStore.joinDate: Timestamp(date: Date())
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
                completion(true)
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
            "userName": comment.user.userName,
            "text": comment.text,
            "createdDate": comment.createdDate,
            "likes": comment.likes.map { $0.userName }
        ]
        
        db.collection("posts").document(postID).collection("comments").addDocument(data: commentData) { error in
            completion(error == nil)
        }
    }
    
    func fetchUserData(for email: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        fetchUserDocumentID(email: email) { documentID in
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
    func fetchUserData(with userName: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        fetchUserDocumentID(userName: userName) { documentID in
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
    func fetchUserDocumentID(email: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user found with the email \(email)")
                completion(nil)
                return
            }
            let documentID = documents[0].documentID
            completion(documentID)
        }
    }
    func fetchUserDocumentID(userName: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("userName", isEqualTo: userName).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No user found with the userName: \(userName)")
                completion(nil)
                return
            }
            let documentID = documents[0].documentID
            completion(documentID)
        }
    }
    func getPosts(for userName: String, completion: @escaping ([String]) -> Void) {
        db.collection("posts")
            .whereField("ownerUserName", isEqualTo: userName)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    completion([])
                } else {
                    let posts = querySnapshot?.documents.compactMap { $0.data()["identifier"] as? String } ?? []
                    completion(posts)
                }
            }
    }
    
    func getFollowers(for userName: String, completion: @escaping ([String]) -> Void) {
        db.collection("follows")
            .whereField("followedUserName", isEqualTo: userName)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching followers: \(error.localizedDescription)")
                    completion([])
                } else {
                    let followers = querySnapshot?.documents.compactMap { $0.data()["followerUserName"] as? String } ?? []
                    completion(followers)
                }
            }
    }
    
    func getFollowing(for userName: String, completion: @escaping ([String]) -> Void) {
        db.collection("follows")
            .whereField("followerUserName", isEqualTo: userName)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching following: \(error.localizedDescription)")
                    completion([])
                } else {
                    let following = querySnapshot?.documents.compactMap { $0.data()["followedUserName"] as? String } ?? []
                    completion(following)
                }
            }
    }
    
    func fetchPostData(for identifier: String, completion: @escaping (UserPost?) -> Void) {
        db.collection("posts")
            .whereField("identifier", isEqualTo: identifier)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching the postData: \(error.localizedDescription)")
                    completion(nil)
                } else if let document = querySnapshot?.documents.first, document.exists {
                    let postData = document.data()
                    guard let ownerUserName = postData["ownerUserName"] as? String else {
                        print("Owner userName not found in post data")
                        completion(nil)
                        return
                    }
                    self.fetchUserData(with: ownerUserName) { result in
                        switch result {
                        case .success(let ownerData):
                            if let userPost = UserPost(documentData: postData, ownerData: ownerData) {
                                completion(userPost)
                            } else {
                                print("Error initializing UserPost")
                                completion(nil)
                            }
                        case .failure(let error):
                            print("Error fetching owner data: \(error.localizedDescription)")
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
    }

    func updateUserData(for userName: String, with data: [String: Any], completion: @escaping (Bool) -> Void) {
        fetchUserDocumentID(userName: userName) { documentID in
            guard let documentID = documentID else {
                completion(false)
                return
            }
            
            let userDocRef = self.db.collection("users").document(documentID)
            userDocRef.updateData(data) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
