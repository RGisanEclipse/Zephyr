//
//  PostRenderViewModel.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import Foundation
struct PostRenderViewModel{
    let renderType: PostRenderType
}
enum PostRenderType{
    case header(provider: UserModel)
    case primaryContent(provider: UserPost)
    case actions(provider: String)
    case comments(comments: [PostComment])
}
