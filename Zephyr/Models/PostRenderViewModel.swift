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
    case header(provider: UserPost)
    case primaryContent(provider: UserPost)
    case actions(provider: UserPost)
    case likes(provider: [PostLike])
    case caption(provider: String)
    case comments(provider: UserPost)
}
