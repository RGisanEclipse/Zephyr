//
//  UserNotificationModel.swift
//  Zephyr
//
//  Created by Eclipse on 06/07/24.
//

import Foundation
struct UserNotificationModel{
    var type: UserNotificationType
    let text: String
    let user: UserModel
    let identifier: String
    let date: Date
}
enum UserNotificationType{
    case like(post: PostSummary)
    case follow(state: FollowState)
}
