//
//  UserNotificationModel.swift
//  Zephyr
//
//  Created by Eclipse on 06/07/24.
//

import Foundation
struct UserNotificationModel{
    let type: UserNotificationType
    let text: String
    let user: UserModel
}
enum UserNotificationType{
    case like(post: PostSummary)
    case follow(state: FollowState)
}
