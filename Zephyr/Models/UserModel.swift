//
//  UserModel.swift
//  Zephyr
//
//  Created by Eclipse on 23/06/24.
//

import Foundation
import FirebaseFirestore
struct UserModel{
    let userName: String
    let profilePicture: URL?
    let bio: String
    let name: (first: String, last: String)?
    let birthDate: Date?
    let gender: Gender?
    var counts: UserCount?
    let joinDate: Date?
    var followers: [FollowerFollowing]
    var following: [FollowerFollowing]
    var posts: [String]
    var savedPosts: [String]
    var email: String
    func isFollower(userName: String) -> Bool {
        return followers.contains(where: { $0.userName == userName })
    }
    func isFollowing(userName: String) -> Bool {
        return following.contains(where: { $0.userName == userName })
    }
    func convertPostLikesToUserRelationships(postLikes: [PostLike]) -> [UserRelationship] {
        return postLikes.map { like in
            let followState: FollowState = isFollowing(userName: like.userName) ? .following : .notFollowing
            return UserRelationship(username: like.userName, profilePicture: like.profilePicture,type: followState)
        }
    }
    func convertFollowerToUserRelationships(with followers: [FollowerFollowing]) -> [UserRelationship] {
        return followers.map { follower in
            let followState: FollowState = isFollowing(userName: follower.userName) ? .following : .notFollowing
            return UserRelationship(username: follower.userName, profilePicture: follower.profilePicture,type: followState)
        }
    }
    
    init?(dictionary: [String: Any]) {
        guard let userName = dictionary["userName"] as? String else {
            return nil
        }
        self.userName = userName
        self.profilePicture = URL(string: dictionary["profilePicture"] as? String ?? "")
        self.bio = dictionary["bio"] as? String ?? ""
        self.name = (first: dictionary["firstName"] as? String ?? "", last: dictionary["lastName"] as? String ?? "")
        self.birthDate = dictionary["birthDate"] as? Date
        self.gender = Gender(rawValue: dictionary["gender"] as? String ?? "") ?? .other
        self.joinDate = dictionary["joinDate"] as? Date
        self.posts = dictionary["posts"] as? [String] ?? []
        self.savedPosts = dictionary["savedPosts"] as? [String] ?? []
        self.followers = dictionary["followers"] as? [FollowerFollowing] ?? []
        self.following = dictionary["following"] as? [FollowerFollowing] ?? []
        self.counts = UserCount(posts: posts.count,
                                followers: followers.count,
                                following: following.count)
        self.email = dictionary["email"] as? String ?? ""
    }
    init(userName: String, profilePicture: URL, bio: String, name: (first: String, last: String), birthDate: Date, gender: Gender, counts: UserCount, joinDate: Date, posts: [String], savedPosts: [String], followers: [FollowerFollowing], following: [FollowerFollowing], email: String) {
        self.userName = userName
        self.profilePicture = profilePicture
        self.bio = bio
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.counts = counts
        self.joinDate = joinDate
        self.posts = posts
        self.savedPosts = savedPosts
        self.followers = followers
        self.following = following
        self.email = email
    }
}
enum Gender: String{
    case male = "Male"
    case female = "Female"
    case other = "Other"
    static func fromString(_ string: String) -> Gender? {
        return Gender(rawValue: string)
    }
}
struct UserCount{
    let posts: Int
    let followers: Int
    let following: Int
}
enum UserPostType: String{
    case photo = "photo"
    case video = "video"
}
struct UserPost {
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL
    let caption: String?
    var likeCount: [PostLike]
    var comments: [PostComment]
    let createDate: Date
    let owner: UserModel
    init?(documentData: [String: Any], ownerData: UserModel){
        guard let identifier = documentData["identifier"] as? String else {
            print("Failed to initialize UserPost: identifier is missing")
            return nil
        }
        self.identifier = identifier
        
        guard let postTypeRawValue = documentData["postType"] as? String else {
            print("Failed to initialize UserPost: postType is missing or not a String")
            return nil
        }
        guard let postType = UserPostType(rawValue: postTypeRawValue) else {
            print("Failed to initialize UserPost: Invalid postType value")
            return nil
        }
        self.postType = postType
        
        guard let thumbnailImageString = documentData["thumbnailImage"] as? String,
              let thumbnailImage = URL(string: thumbnailImageString) else {
            print("Failed to initialize UserPost: thumbnailImage URL is missing or invalid")
            return nil
        }
        self.thumbnailImage = thumbnailImage
        
        guard let postURLString = documentData["postURL"] as? String,
              let postURL = URL(string: postURLString) else {
            print("Failed to initialize UserPost: postURL URL is missing or invalid")
            return nil
        }
        self.postURL = postURL
        
        guard let createDateTimestamp = documentData["createDate"] as? Timestamp else {
            print("Failed to initialize UserPost: createDate Timestamp is missing")
            return nil
        }
        self.createDate = createDateTimestamp.dateValue()
        self.owner = ownerData
        self.caption = documentData["caption"] as? String
        self.likeCount = []
        self.comments = []
    }
    init(identifier: String, postType: UserPostType, thumbnailImage: URL, postURL: URL, caption: String?, likeCount: [PostLike], comments: [PostComment], createDate: Date, owner: UserModel) {
        self.identifier = identifier
        self.postType = postType
        self.thumbnailImage = thumbnailImage
        self.postURL = postURL
        self.caption = caption
        self.likeCount = likeCount
        self.comments = comments
        self.createDate = createDate
        self.owner = owner
    }
}

struct PostLike{
    let userName: String
    let profilePicture: String?
    let postIdentifier: String
}
struct CommentLike{
    let userName: String
    let commentIdentifier: String
}
struct PostComment{
    let postIdentifier: String
    let userName: String
    let profilePicture: String
    let text: String
    let createdDate: Date
    var likes: [CommentLike]
    let commentIdentifier: String
    init?(from dictionary: [String: Any]) {
            guard
                let postIdentifier = dictionary["postIdentifier"] as? String,
                let userName = dictionary["userName"] as? String,
                let profilePicture = dictionary["profilePicture"] as? String,
                let text = dictionary["text"] as? String,
                let createdDateTimestamp = dictionary["createdDate"] as? Timestamp,
                let commentIdentifier = dictionary["commentIdentifier"] as? String
            else {
                return nil
            }
            let createdDate = createdDateTimestamp.dateValue()
            let likes: [CommentLike] = []
            self.postIdentifier = postIdentifier
            self.userName = userName
            self.profilePicture = profilePicture
            self.text = text
            self.createdDate = createdDate
            self.likes = likes
            self.commentIdentifier = commentIdentifier
        }
    init(postIdentifier: String, userName: String, profilePicture: String, text: String, createdDate: Date, likes: [CommentLike], commentIdentifier: String){
        self.postIdentifier = postIdentifier
        self.userName = userName
        self.profilePicture = profilePicture
        self.text = text
        self.createdDate = createdDate
        self.likes = likes
        self.commentIdentifier = commentIdentifier
    }
}
enum FollowState {
    case following, notFollowing
}

struct PostSummary{
    let identifier: String
    let thumbnailImage: URL
    let postType: UserPostType
}

struct UserRelationship {
    let username: String
    let profilePicture: String?
    var type: FollowState
}

struct FollowerFollowing {
    let userName: String
    let profilePicture: String
}

enum selectedView{
    case posts
    case videoPosts
    case savedPosts
}
enum userProfileSelectedView{
    case posts
    case videoPosts
}
