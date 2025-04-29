//
//  DatabaseManager.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import FirebaseFirestore
import FirebaseAuth
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
            Constants.FireStore.joinDate: Timestamp(date: Date()),
            Constants.FireStore.gender: Gender.other.rawValue
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
    func followUser(followerUserName: String, followedUserName: String, followerProfilePicture: String, followedUserProfilePicture: String, completion: @escaping (Bool) -> Void) {
        let followData: [String: Any] = [
            "followerUserName": followerUserName,
            "followedUserName": followedUserName,
            "followedUserProfilePicture": followedUserProfilePicture,
            "followerProfilePicture": followerProfilePicture
        ]
        db.collection("follows").addDocument(data: followData) { error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func unfollowUser(followerUserName: String, followedUserName: String, completion: @escaping (Bool) -> Void) {
        let followsRef = db.collection("follows")
        followsRef.whereField("followerUserName", isEqualTo: followerUserName)
            .whereField("followedUserName", isEqualTo: followedUserName)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error unfollowing user: \(error.localizedDescription)")
                    completion(false)
                } else {
                    guard let documents = snapshot?.documents else {
                        completion(false)
                        return
                    }
                    for document in documents {
                        document.reference.delete { error in
                            if let error = error {
                                print("Error deleting follow document: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
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
            "ownerUserName": post.owner.userName,
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
    func deletePost(with identifier: String, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("posts").document(identifier)
        postRef.delete { error in
            if let error = error {
                print("Error deleting post: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    func reportPost(_ post: UserPost, completion: @escaping (Bool) -> Void) {
        let postRef = db.collection("reportedPosts").document(post.identifier)
        postRef.getDocument { (document, error) in
            if let document = document, document.exists {
                postRef.updateData([
                    "numberOfReports": FieldValue.increment(Int64(1))
                ]) { error in
                    if let error = error {
                        print("Error updating post: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                completion(false)
            } else {
                let postData: [String: Any] = [
                    "identifier": post.identifier,
                    "postType": post.postType == .photo ? "photo" : "video",
                    "numberOfReports": 1
                ]
                postRef.setData(postData) { error in
                    if let error = error {
                        print("Error saving post: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    func addLike(to postID: String, from user: UserModel, completion: @escaping (Bool) -> Void) {
        let likeData: [String: Any] = [
            "userName": user.userName,
            "profilePicture": user.profilePicture?.absoluteString ?? "",
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
            "userName": comment.userName,
            "text": comment.text,
            "createdDate": comment.createdDate,
            "likes": comment.likes.map { $0.userName },
            "postIdentifier": postID,
            "commentIdentifier": comment.commentIdentifier,
            "profilePicture": comment.profilePicture
        ]
        
        db.collection("postComments").addDocument(data: commentData) { error in
            completion(error == nil)
        }
    }
    func fetchComment(with commentID: String, completion: @escaping (PostComment?) -> Void) {
        let commentsRef = db.collection("postComments")
        commentsRef.document(commentID).getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching comment: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let document = documentSnapshot, document.exists,
                  let data = document.data() else {
                print("Comment not found or no data available")
                completion(nil)
                return
            }
            guard let postComment = PostComment(from: data) else {
                print("Error: Unable to convert document data to PostComment")
                completion(nil)
                return
            }
            completion(postComment)
        }
    }
    func reportComment(comment: PostComment, completion: @escaping (Bool) -> Void) {
        let commentData: [String: Any] = [
            "userName": comment.userName,
            "text": comment.text,
            "createdDate": comment.createdDate,
            "likes": comment.likes.map { $0.userName },
            "postIdentifier": comment.postIdentifier,
            "commentIdentifier": comment.commentIdentifier,
            "profilePicture": comment.profilePicture
        ]
        db.collection("reportedComments").addDocument(data: commentData) { error in
            completion(error == nil)
        }
    }
    func deleteComment(from postID: String, comment: PostComment, completion: @escaping (Bool) -> Void) {
        let commentsRef = db.collection("postComments")
        let likesRef = db.collection("commentLikes")
        commentsRef.whereField("commentIdentifier", isEqualTo: comment.commentIdentifier).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding comment: \(error)")
                completion(false)
                return
            }
            guard let commentDocument = querySnapshot?.documents.first else {
                print("Comment not found")
                completion(false)
                return
            }
            likesRef.whereField("commentIdentifier", isEqualTo: comment.commentIdentifier).getDocuments { (likesSnapshot, error) in
                if let error = error {
                    print("Error finding comment likes: \(error)")
                    completion(false)
                    return
                }
                let batch = self.db.batch()
                batch.deleteDocument(commentDocument.reference)
                likesSnapshot?.documents.forEach { likeDocument in
                    batch.deleteDocument(likeDocument.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error removing comment and likes: \(error)")
                        completion(false)
                    } else {
                        print("Comment and associated likes successfully removed")
                        completion(true)
                    }
                }
            }
        }
    }
    func addCommentLike(to commentIdentifier: String, by user: UserModel, completion: @escaping (Bool) -> Void) {
        let likeData: [String: Any] = [
            "userName": user.userName,
            "commentIdentifier": commentIdentifier
        ]
        db.collection("commentLikes").addDocument(data: likeData) { error in
            completion(error == nil)
        }
    }
    func removeCommentLike(from commentIdentifier: String, by user: UserModel, completion: @escaping (Bool) -> Void) {
        db.collection("commentLikes")
            .whereField("commentIdentifier", isEqualTo: commentIdentifier)
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
                self.db.collection("commentLikes").document(documentID).delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
    func addToSavedPosts(post postID: String, from userName: String, completion: @escaping (Bool) -> Void) {
        let savedPostData: [String: Any] = [
            "userName": userName,
            "postIdentifier": postID,
            "saveDate": Date()
        ]
        db.collection("savedPosts").addDocument(data: savedPostData) { error in
            completion(error == nil)
        }
    }
    
    func removeFromSavedPosts(post identifier: String, from userName: String, completion: @escaping (Bool) -> Void) {
        let query = db.collection("savedPosts")
            .whereField("postIdentifier", isEqualTo: identifier)
            .whereField("userName", isEqualTo: userName)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching saved post: \(error)")
                completion(false)
                return
            }
            
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                print("No saved post found for the provided post ID and userName.")
                completion(false)
                return
            }
            
            let document = snapshot.documents.first
            document?.reference.delete { error in
                if let error = error {
                    print("Error deleting saved post: \(error)")
                    completion(false)
                } else {
                    print("Successfully removed the saved post.")
                    completion(true)
                }
            }
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
    func fetchUsers(matching prefix: String, completion: @escaping (Result<[UserModel], Error>) -> Void) {
        let usersRef = self.db.collection("users")
        let query = usersRef
            .whereField("userName", isGreaterThanOrEqualTo: prefix)
            .whereField("userName", isLessThan: prefix + "\u{f8ff}")
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let currentUserEmail = Auth.auth().currentUser?.email
            let userModels = documents.compactMap { document -> UserModel? in
                let data = document.data()
                if let email = data["email"] as? String, email == currentUserEmail {
                    return nil
                }
                return UserModel(dictionary: data)
            }
            completion(.success(userModels))
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
    func getSavedPosts(for userName: String, completion: @escaping ([String]) -> Void){
        db.collection("savedPosts")
            .whereField("userName", isEqualTo: userName)
            .order(by: "saveDate", descending: true)
            .getDocuments() { querySnapshot, error in
                if let error = error {
                    print("Error fetching saved posts: \(error.localizedDescription)")
                    completion([])
                } else {
                    let posts = querySnapshot?.documents.compactMap { $0.data()["postIdentifier"] as? String } ?? []
                    completion(posts)
                }
            }
    }
    
    func getFollowers(for userName: String, completion: @escaping ([FollowerFollowing]) -> Void) {
        db.collection("follows")
            .whereField("followedUserName", isEqualTo: userName)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching followers: \(error.localizedDescription)")
                    completion([])
                } else {
                    let followers = querySnapshot?.documents.compactMap { document -> FollowerFollowing? in
                        let data = document.data()
                        let userName = data["followerUserName"] as? String ?? ""
                        let profilePicture = data["followerProfilePicture"] as? String ?? ""
                        return FollowerFollowing(userName: userName, profilePicture: profilePicture)
                    } ?? []
                    completion(followers)
                }
            }
    }
    
    func getFollowing(for userName: String, completion: @escaping ([FollowerFollowing]) -> Void) {
        db.collection("follows")
            .whereField("followerUserName", isEqualTo: userName)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching following: \(error.localizedDescription)")
                    completion([])
                } else {
                    let following = querySnapshot?.documents.compactMap { document -> FollowerFollowing? in
                        let data = document.data()
                        let followedUserName = data["followedUserName"] as? String ?? ""
                        let profilePicture = data["followedUserProfilePicture"] as? String ?? ""
                        return FollowerFollowing(userName: followedUserName, profilePicture: profilePicture)
                    } ?? []
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
                              let profilePicture = data["profilePicture"] as? String,
                              let postIdentifier = data["postIdentifier"] as? String else {
                            return nil
                        }
                        return PostLike(userName: userName, profilePicture: profilePicture,postIdentifier: postIdentifier)
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
    func fetchRandomPosts(completion: @escaping ([HomeRenderViewModel]) -> Void) {
        db.collection("posts")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    completion([])
                    return
                }
                var posts: [UserPost] = []
                let dispatchGroup = DispatchGroup()
                for document in querySnapshot?.documents ?? [] {
                    let postData = document.data()
                    guard let ownerUserName = postData["ownerUserName"] as? String else {
                        print("Owner userName not found in post data")
                        continue
                    }
                    dispatchGroup.enter()
                    self.fetchUserData(with: ownerUserName) { result in
                        switch result {
                        case .success(let ownerData):
                            guard var userPost = UserPost(documentData: postData, ownerData: ownerData) else {
                                print("Error initializing UserPost")
                                dispatchGroup.leave()
                                return
                            }
                            let postDispatchGroup = DispatchGroup()
                            postDispatchGroup.enter()
                            self.fetchPostLikes(for: userPost.identifier) { likes in
                                if let likes = likes {
                                    userPost.likeCount = likes
                                } else {
                                    print("Error fetching post likes")
                                }
                                postDispatchGroup.leave()
                            }
                            
                            postDispatchGroup.enter()
                            self.fetchPostComments(for: userPost.identifier) { comments in
                                if let comments = comments {
                                    userPost.comments = comments
                                } else {
                                    print("Error fetching post comments")
                                }
                                postDispatchGroup.leave()
                            }
                            postDispatchGroup.notify(queue: .main) {
                                posts.append(userPost)
                                dispatchGroup.leave()
                            }
                        case .failure(let error):
                            print("Error fetching owner data: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    let shuffledPosts = posts.shuffled()
                    var renderModels: [HomeRenderViewModel] = []
                    
                    for post in shuffledPosts {
                        let viewModel = HomeRenderViewModel(
                            header: PostRenderViewModel(renderType: .header(provider: post)),
                            post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                            actions: PostRenderViewModel(renderType: .actions(provider: post)),
                            likes: PostRenderViewModel(renderType: .likes(provider: post.likeCount)),
                            caption: PostRenderViewModel(renderType: .caption(provider: post.caption ?? "")),
                            comments: PostRenderViewModel(renderType: .comments(provider: post))
                        )
                        renderModels.append(viewModel)
                    }
                    completion(renderModels)
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
    func fetchAllPostSummaries(completion: @escaping ([PostSummary]?) -> Void) {
        db.collection("posts")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No posts found")
                    completion(nil)
                    return
                }
                
                var postSummaries: [PostSummary] = []
                let dispatchGroup = DispatchGroup()
                
                for document in documents {
                    let postIdentifier = document.documentID
                    
                    dispatchGroup.enter()
                    DatabaseManager.shared.fetchPostSummary(for: postIdentifier) { postSummary in
                        if let postSummary = postSummary {
                            postSummaries.append(postSummary)
                        } else {
                            print("Failed to fetch summary for post \(postIdentifier)")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    let shuffledSummaries = postSummaries.shuffled()
                    completion(shuffledSummaries)
                }
            }
    }
    
    func fetchPostComments(for postIdentifier: String, completion: @escaping ([PostComment]?) -> Void) {
        db.collection("postComments")
            .whereField("postIdentifier", isEqualTo: postIdentifier)
            .order(by: "createdDate", descending: true)
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
                    guard let identifier = commentData["postIdentifier"] as? String,
                          let userName = commentData["userName"] as? String,
                          let text = commentData["text"] as? String,
                          let commentIdentifier = commentData["commentIdentifier"] as? String,
                          let profilePicture = commentData["profilePicture"] as? String,
                          let timestamp = commentData["createdDate"] as? Timestamp else {
                        continue
                    }
                    
                    let createdDate = timestamp.dateValue()
                    dispatchGroup.enter()
                    self.fetchCommentLikes(for: commentIdentifier) { likes in
                        let completedComment = PostComment(
                            postIdentifier: identifier,
                            userName: userName,
                            profilePicture: profilePicture,
                            text: text,
                            createdDate: createdDate,
                            likes: likes,
                            commentIdentifier: commentIdentifier
                        )
                        comments.append(completedComment)
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(comments)
                }
            }
    }
    func fetchCommentLikes(for commentIdentifier: String, completion: @escaping ([CommentLike]) -> Void) {
        db.collection("commentLikes")
            .whereField("commentIdentifier", isEqualTo: commentIdentifier)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching comment likes: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }
                
                let likes = documents.map { document -> CommentLike in
                    let data = document.data()
                    let userName = data["userName"] as? String ?? ""
                    return CommentLike(userName: userName, commentIdentifier: commentIdentifier)
                }
                completion(likes)
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
    func deleteLikes(for postID: String, completion: @escaping (Bool) -> Void) {
        db.collection("postLikes")
            .whereField("postIdentifier", isEqualTo: postID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching likes: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                let batch = self.db.batch()
                querySnapshot?.documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("Error deleting likes: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
    func deleteComments(for postID: String, completion: @escaping (Bool) -> Void) {
        let commentsRef = db.collection("postComments")
        commentsRef.whereField("postIdentifier", isEqualTo: postID).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching comments: \(error.localizedDescription)")
                completion(false)
                return
            }
            let documents = querySnapshot?.documents ?? []
            let totalComments = documents.count
            if totalComments == 0 {
                completion(true)
                return
            }
            let dispatchGroup = DispatchGroup()
            var deleteErrorOccurred = false
            for document in documents {
                dispatchGroup.enter()
                let commentID = document.documentID
                self.fetchComment(with: commentID) { fetchedComment in
                    guard let fetchedComment = fetchedComment else {
                        deleteErrorOccurred = true
                        dispatchGroup.leave()
                        return
                    }
                    self.deleteComment(from: postID, comment: fetchedComment) { success in
                        if !success {
                            deleteErrorOccurred = true
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                if deleteErrorOccurred {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func addNotification(to userName: String, from user: UserModel, type: String, post: PostSummary?,notificationText: String ,completion: @escaping (Bool) -> Void) {
        let notificationID = UUID().uuidString
        guard let post = post else{
            let notificationData: [String: Any] = [
                "notificationID": notificationID,
                "type": type,
                "text": notificationText,
                "userName": userName,
                "followerUserName": user.userName,
                "profilePictureURL": user.profilePicture?.absoluteString ?? "",
                "timestamp": FieldValue.serverTimestamp()
            ]
            db.collection("notifications").addDocument(data: notificationData) { error in
                completion(error == nil)
            }
            return
        }
        let notificationData: [String: Any] = [
            "notificationID": notificationID,
            "type": type,
            "text": notificationText,
            "userName": userName,
            "fromUserName": user.userName,
            "profilePictureURL": user.profilePicture?.absoluteString ?? "",
            "identifier": post.identifier,
            "thumbnailImageURL": post.thumbnailImage.absoluteString,
            "postType": post.postType.rawValue,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("notifications").addDocument(data: notificationData) { error in
            completion(error == nil)
        }
    }
    func removeNotification(notificationID: String, completion: @escaping (Bool) -> Void) {
        let notificationRef = db.collection("notifications")
        notificationRef
            .whereField("notificationID", isEqualTo: notificationID)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(error?.localizedDescription ?? "No error description")")
                    completion(false)
                    return
                }
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting document: \(error)")
                            completion(false)
                            return
                        }
                    }
                }
                completion(true)
            }
    }
    func deleteNotifications(for postIdentifier: String, completion: @escaping (Bool) -> Void) {
        let notificationRef = db.collection("notifications")
        notificationRef
            .whereField("identifier", isEqualTo: postIdentifier)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(error?.localizedDescription ?? "No error description")")
                    completion(false)
                    return
                }
                let batch = self.db.batch()
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error deleting documents: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
    func fetchNotificationIDforLike(for userName: String, by likerUserName: String,postIdentifier: String, completion: @escaping (String?) -> Void) {
        db.collection("notifications")
            .whereField("userName", isEqualTo: userName)
            .whereField("identifier", isEqualTo: postIdentifier)
            .whereField("text", isEqualTo: "\(likerUserName) liked your post.")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(error?.localizedDescription ?? "No error description")")
                    completion(nil)
                    return
                }
                if let document = documents.first {
                    let notificationID = document.data()["notificationID"] as? String
                    completion(notificationID)
                } else {
                    completion(nil)
                }
            }
    }
    func fetchNotificationIDforComment(for userName: String, by commenterUserName: String, postIdentifier: String, comment: String, completion: @escaping (String?) -> Void) {
        db.collection("notifications")
            .whereField("userName", isEqualTo: userName)
            .whereField("identifier", isEqualTo: postIdentifier)
            .whereField("text", isEqualTo: "\(commenterUserName) commented on your post: \(comment)")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(error?.localizedDescription ?? "No error description")")
                    completion(nil)
                    return
                }
                if let document = documents.first {
                    let notificationID = document.data()["notificationID"] as? String
                    completion(notificationID)
                } else {
                    completion(nil)
                }
            }
    }
    func fetchNotificationIDforFollow(for userName: String, with followerUserName: String, completion: @escaping (String?) -> Void) {
        db.collection("notifications")
            .whereField("userName", isEqualTo: userName)
            .whereField("followerUserName", isEqualTo: followerUserName)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(error?.localizedDescription ?? "No error description")")
                    completion(nil)
                    return
                }
                if let document = documents.first {
                    let notificationID = document.data()["notificationID"] as? String
                    completion(notificationID)
                } else {
                    completion(nil)
                }
            }
    }
    func fetchNotificationIDforCommentLike(for userName: String, by commenterUserName: String, post: UserPost, comment: String, completion: @escaping (String?) -> Void) {
        db.collection("notifications")
            .whereField("userName", isEqualTo: userName)
            .whereField("identifier", isEqualTo: post.identifier)
            .whereField("text", isEqualTo: "\(commenterUserName) liked your comment on \(post.owner.userName)'s post: \(comment)")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(error?.localizedDescription ?? "No error description")")
                    completion(nil)
                    return
                }
                if let document = documents.first {
                    let notificationID = document.data()["notificationID"] as? String
                    completion(notificationID)
                } else {
                    completion(nil)
                }
            }
    }
    
    func fetchNotificationsForUser(user: UserModel, completion: @escaping ([UserNotificationModel]) -> Void) {
        db.collection("notifications")
            .whereField("userName", isEqualTo: user.userName)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching notifications: \(String(describing: error))")
                    completion([])
                    return
                }
                var notifications: [UserNotificationModel] = []
                let group = DispatchGroup()
                for document in documents {
                    let data = document.data()
                    guard let typeString = data["type"] as? String,
                          let text = data["text"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        continue
                    }
                    group.enter()
                    if typeString == "follow" {
                        guard let followerUserName = data["followerUserName"] as? String else {
                            group.leave()
                            return
                        }
                        self.fetchUserData(with: followerUserName) { result in
                            switch result {
                            case .success(let fetchedUserData):
                                let followState = user.isFollowing(userName: followerUserName)
                                let followType: FollowState = followState ? .following : .notFollowing
                                let notification = UserNotificationModel(
                                    type: .follow(state: followType),
                                    text: text,
                                    user: fetchedUserData,
                                    identifier: document.documentID,
                                    date: timestamp.dateValue()
                                )
                                notifications.append(notification)
                            case .failure(let error):
                                print("Error fetching userData: \(error)")
                            }
                            group.leave()
                        }
                    } else if typeString == "like",
                              let fromUserName = data["fromUserName"] as? String,
                              let postIdentifier = data["identifier"] as? String,
                              let thumbnailImageURLString = data["thumbnailImageURL"] as? String,
                              let thumbnailImageURL = URL(string: thumbnailImageURLString),
                              let postTypeRaw = data["postType"] as? String,
                              let postType = UserPostType(rawValue: postTypeRaw) {
                        
                        self.fetchUserData(with: fromUserName) { result in
                            switch result {
                            case .success(let fetchedUserData):
                                let post = PostSummary(
                                    identifier: postIdentifier,
                                    thumbnailImage: thumbnailImageURL,
                                    postType: postType
                                )
                                let notification = UserNotificationModel(
                                    type: .like(post: post),
                                    text: text,
                                    user: fetchedUserData,
                                    identifier: document.documentID,
                                    date: timestamp.dateValue()
                                )
                                notifications.append(notification)
                            case .failure(let error):
                                print("Error fetching userData: \(error)")
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(notifications)
                }
            }
    }
    public func checkIfEmailExists(email: String, completion: @escaping (Bool) -> Void){
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(false)
                    return
                }
                if let snapshot = snapshot, !snapshot.isEmpty {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    public func checkIfUserNameExists(_ userName: String, completion: @escaping (Bool) -> Void) {
        let usersRef = DatabaseManager.shared.db.collection("users")
        usersRef.whereField("userName", isEqualTo: userName).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking username: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                completion(true)
            } else {
                completion(false) 
            }
        }
    }
}
