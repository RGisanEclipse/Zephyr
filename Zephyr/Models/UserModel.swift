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
        self.followers = dictionary["followers"] as? [String] ?? []
        self.following = dictionary["following"] as? [String] ?? []
        self.counts = UserCount(posts: 0,
                                    followers: followers.count,
                                    following: following.count)
    }
    init(userName: String, profilePicture: URL, bio: String, name: (first: String, last: String), birthDate: Date, gender: Gender, counts: UserCount, joinDate: Date, followers: [String], following: [String]) {
        self.userName = userName
        self.profilePicture = profilePicture
        self.bio = bio
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.counts = counts
        self.joinDate = joinDate
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
enum UserPostType{
    case photo, video
}
struct UserPost{
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createDate: Date
    let taggedUsers: [String]
    let owner: UserModel
}
struct PostLike{
    let userName: String
    let postIdentifier: String
}
struct CommentLike{
    let userName: String
    let postIdentifier: String
}
struct PostComment{
    let identifier: String
    let user: UserModel
    let text: String
    let createdDate: Date
    let likes: [CommentLike]
}
enum FollowState {
    case following, notFollowing
}

struct UserRelationship {
    let username: String
    var type: FollowState
}
