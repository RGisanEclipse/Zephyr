//
//  UserModel.swift
//  Zephyr
//
//  Created by Eclipse on 23/06/24.
//

import Foundation
struct UserModel{
    let userName: String
    let profilePicture: URL
    let bio: String
    let name: (first: String, last: String)
    let birthDate: Date
    let gender: Gender
    let counts: UserCount
    let joinDate: Date
}
enum Gender{
    case male, female, other
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
