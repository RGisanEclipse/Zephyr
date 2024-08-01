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
        
        db.collection("postLikes").addDocument(data: likeData) { error in
            completion(error == nil)
        }
    }
    func removeLike(to postID: String, from user: UserModel, completion: @escaping (Bool) -> Void) {
        db.collection("postLikes")
            .whereField("postIdentifier", isEqualTo: postID)
            .whereField("userName", isEqualTo: user.userName)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    completion(false)
                    return
                }
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    completion(false)
                    return
                }
                let documentID = documents.first!.documentID
                self.db.collection("postLikes").document(documentID).delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
    
    func addComment(to postID: String, comment: PostComment, completion: @escaping (Bool) -> Void) {
        let commentData: [String: Any] = [
            "identifier": comment.identifier,
            "userName": comment.user.userName,
            "text": comment.text,
            "createdDate": comment.createdDate,
            "likes": comment.likes.map { $0.userName },
            "postIdentifier": postID
        ]
        
        db.collection("postComments").addDocument(data: commentData) { error in
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
            .order(by: "createDate", descending: true)
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
    
    func fetchPostLikes(for postIdentifier: String, completion: @escaping ([PostLike]?) -> Void) {
        db.collection("postLikes")
            .whereField("postIdentifier", isEqualTo: postIdentifier)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching post likes: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    let likes = querySnapshot?.documents.compactMap { document -> PostLike? in
                        let data = document.data()
                        guard let userName = data["userName"] as? String,
                              let postIdentifier = data["postIdentifier"] as? String else {
                            return nil
                        }
                        return PostLike(userName: userName, postIdentifier: postIdentifier)
                    }
                    completion(likes)
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
                    return
                }
                guard let document = querySnapshot?.documents.first, document.exists else {
                    completion(nil)
                    return
                }
                let postData = document.data()
                guard let ownerUserName = postData["ownerUserName"] as? String else {
                    print("Owner userName not found in post data")
                    completion(nil)
                    return
                }
                self.fetchUserData(with: ownerUserName) { result in
                    switch result {
                    case .success(let ownerData):
                        guard var userPost = UserPost(documentData: postData, ownerData: ownerData) else {
                            print("Error initializing UserPost")
                            completion(nil)
                            return
                        }
                        
                        let dispatchGroup = DispatchGroup()
                        dispatchGroup.enter()
                        self.fetchPostLikes(for: identifier) { likes in
                            if let likes = likes {
                                userPost.likeCount = likes
                            } else {
                                print("Error fetching post likes")
                            }
                            dispatchGroup.leave()
                        }
                        dispatchGroup.enter()
                        self.fetchPostComments(for: identifier) { comments in
                            if let comments = comments {
                                userPost.comments = comments
                            } else {
                                print("Error fetching post comments")
                            }
                            dispatchGroup.leave()
                        }
                        dispatchGroup.notify(queue: .main) {
                            completion(userPost)
                        }
                    case .failure(let error):
                        print("Error fetching owner data: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            }
    }
    func fetchPostSummary(for postIdentifier: String, completion: @escaping (PostSummary?) -> Void) {
        db.collection("posts")
            .whereField("identifier", isEqualTo: postIdentifier)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching post summary: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let document = querySnapshot?.documents.first else {
                    print("No post found with identifier \(postIdentifier)")
                    completion(nil)
                    return
                }
                if let thumbnailImageString = document.data()["thumbnailImage"] as? String,
                   let thumbnailImageURL = URL(string: thumbnailImageString) {
                    let postTypeRawValue = document.data()["postType"] as? String
                    let postType = UserPostType(rawValue: postTypeRawValue!)
                    let postSummary = PostSummary(identifier: postIdentifier, thumbnailImage: thumbnailImageURL, postType: postType!)
                    completion(postSummary)
                } else {
                    print("Thumbnail image URL is invalid or not found")
                    let placeholderURL = URL(string: "")!
                    let postTypeRawValue = document.data()["postType"] as? String
                    let postType = UserPostType(rawValue: postTypeRawValue!)
                    let postSummary = PostSummary(identifier: postIdentifier, thumbnailImage: placeholderURL, postType: postType!)
                    completion(postSummary)
                }
            }
    }
    func fetchPostComments(for postIdentifier: String, completion: @escaping ([PostComment]?) -> Void) {
        db.collection("postComments")
            .whereField("postIdentifier", isEqualTo: postIdentifier)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching post comments: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }
                let commentsData = documents.map { $0.data() }
                var comments: [PostComment] = []
                let dispatchGroup = DispatchGroup()
                
                for commentData in commentsData {
                    guard let identifier = commentData["identifier"] as? String,
                          let userName = commentData["userName"] as? String,
                          let text = commentData["text"] as? String,
                          let timestamp = commentData["createdDate"] as? Timestamp else {
                        continue
                    }
                    
                    let createdDate = timestamp.dateValue()
                    let likesUserNames = commentData["likes"] as? [String] ?? []
                    let likes = likesUserNames.map { PostLike(userName: $0, postIdentifier: postIdentifier) }
                    
                    dispatchGroup.enter()
                    self.fetchUserData(with: userName) { result in
                        switch result {
                        case .success(let userModel):
                            let completedComment = PostComment(identifier: identifier, user: userModel, text: text, createdDate: createdDate, likes: [])
                            comments.append(completedComment)
                        case .failure(let error):
                            print("Error fetching commenter data: \(error.localizedDescription)")
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(comments)
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
