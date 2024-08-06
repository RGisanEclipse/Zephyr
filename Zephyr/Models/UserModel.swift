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
    var followers: [String]
    var following: [String]
    var posts: [String]
    func isFollower(userName: String) -> Bool {
        return followers.contains(userName)
    }
    func isFollowing(userName: String) -> Bool{
        return following.contains(userName)
    }
    func convertPostLikesToUserRelationships(postLikes: [PostLike]) -> [UserRelationship] {
        return postLikes.map { like in
            let followState: FollowState = isFollower(userName: like.userName) ? .following : .notFollowing
            return UserRelationship(username: like.userName, type: followState)
        }
    }
    func convertFollowerToUserRelationships(with followers: [String]) -> [UserRelationship] {
        return followers.map { username in
            let followState: FollowState = isFollowing(userName: username) ? .following : .notFollowing
            return UserRelationship(username: username, type: followState)
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
        self.followers = dictionary["followers"] as? [String] ?? []
        self.following = dictionary["following"] as? [String] ?? []
        self.counts = UserCount(posts: posts.count,
                                followers: followers.count,
                                following: following.count)
    }
    init(userName: String, profilePicture: URL, bio: String, name: (first: String, last: String), birthDate: Date, gender: Gender, counts: UserCount, joinDate: Date, posts: [String], followers: [String], following: [String]) {
        self.userName = userName
        self.profilePicture = profilePicture
        self.bio = bio
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.counts = counts
        self.joinDate = joinDate
        self.posts = posts
        self.followers = followers
        self.following = following
    }
}
enum Gender: String{
    case male = "male"
    case female = "female"
    case other = "other"
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
    let taggedUsers: [String]
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
        self.taggedUsers = documentData["taggedUsers"] as? [String] ?? []
    }
    init(identifier: String, postType: UserPostType, thumbnailImage: URL, postURL: URL, caption: String?, likeCount: [PostLike], comments: [PostComment], createDate: Date, taggedUsers: [String], owner: UserModel) {
        self.identifier = identifier
        self.postType = postType
        self.thumbnailImage = thumbnailImage
        self.postURL = postURL
        self.caption = caption
        self.likeCount = likeCount
        self.comments = comments
        self.createDate = createDate
        self.taggedUsers = taggedUsers
        self.owner = owner
    }
}

struct PostLike{
    let userName: String
    let postIdentifier: String
}
struct CommentLike{
    let userName: String
    let commentIdentifier: String
}
struct PostComment{
    let postIdentifier: String
    let user: UserModel
    let text: String
    let createdDate: Date
    var likes: [CommentLike]
    let commentIdentifier: String
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
    var type: FollowState
}
