//
//  UserDataManager.swift
//  Zephyr
//
//  Created by Eclipse on 07/08/24.
//

import Foundation
class UserDataManager {
    public static var shared = UserDataManager()
    var userData: UserModel?
    public func fetchUserData(with userName: String, completion: @escaping (UserModel?, Bool) -> Void) {
        DatabaseManager.shared.fetchUserData(with: userName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let userName = user.userName
                let dispatchGroup = DispatchGroup()
                var posts: [String] = []
                var followers: [FollowerFollowing] = []
                var following: [FollowerFollowing] = []
                
                dispatchGroup.enter()
                DatabaseManager.shared.getPosts(for: userName){ fetchedPosts in
                    posts = fetchedPosts
                    dispatchGroup.leave()
                }
                dispatchGroup.enter()
                DatabaseManager.shared.getFollowers(for: userName) { fetchedFollowers in
                    followers = fetchedFollowers
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                DatabaseManager.shared.getFollowing(for: userName) { fetchedFollowing in
                    following = fetchedFollowing
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    let updatedCounts = UserCount(posts: posts.count, followers: followers.count, following: following.count)
                    var updatedUser = user
                    updatedUser.posts = posts
                    updatedUser.followers = followers
                    updatedUser.following = following
                    updatedUser.counts = updatedCounts
                    self.userData = updatedUser
                    completion(updatedUser, true)
                }
            case .failure(let error):
                print("Failed to fetch user data: \(error)")
                completion(nil, false)
            }
        }
    }
}

