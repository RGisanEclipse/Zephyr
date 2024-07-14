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
    let profilePicture: URL
    let bio: String
    let name: (first: String, last: String)
    let birthDate: Date
    let gender: Gender
    let counts: UserCount
    let joinDate: Date
    let followers: [String]
    let following: [String]
    func isFollower(userName: String) -> Bool {
        return followers.contains(userName)
    }
    func convertPostLikesToUserRelationships(postLikes: [PostLike]) -> [UserRelationship] {
        return postLikes.map { like in
            let followState: FollowState = isFollower(userName: like.userName) ? .following : .notFollowing
            return UserRelationship(username: like.userName, type: followState)
        }
    }
    init?(dictionary: [String: Any]) {
        guard let userName = dictionary["userName"] as? String else {
            print("Missing userName")
            return nil
        }
        guard let profilePictureString = dictionary["profilePicture"] as? String,
              let profilePicture = URL(string: profilePictureString) else {
            print("Invalid profilePicture")
            return nil
        }
        guard let bio = dictionary["bio"] as? String else {
            print("Missing bio")
            return nil
        }
        guard let nameDict = dictionary["name"] as? [String: String],
              let firstName = nameDict["first"],
              let lastName = nameDict["last"] else {
            print("Invalid name")
            return nil
        }
        guard let birthDateTimestamp = dictionary["birthDate"] as? Timestamp else {
            print("Missing birthDate")
            return nil
        }
        guard let genderString = dictionary["gender"] as? String else {
            print("Missing gender")
            return nil
        }
        guard let countsDict = dictionary["counts"] as? [String: Int] else {
            print("Invalid counts")
            return nil
        }
        guard let joinDateTimestamp = dictionary["joinDate"] as? Timestamp else {
            print("Missing joinDate")
            return nil
        }
        guard let followers = dictionary["followers"] as? [String] else {
            print("Missing followers")
            return nil
        }
        guard let following = dictionary["following"] as? [String] else {
            print("Missing following")
            return nil
        }
        // Initialize properties
        self.userName = userName
        self.profilePicture = profilePicture
        self.bio = bio
        self.name = (first: firstName, last: lastName)
        self.birthDate = birthDateTimestamp.dateValue()
        self.gender = Gender.fromString(genderString) ?? .other
        self.counts = UserCount(posts: countsDict["posts"] ?? 0,
                                followers: countsDict["followers"] ?? 0,
                                following: countsDict["following"] ?? 0)
        self.joinDate = joinDateTimestamp.dateValue()
        self.followers = followers
        self.following = following
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
