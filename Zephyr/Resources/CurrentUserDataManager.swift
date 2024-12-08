//
//  CurrentUserDataManager.swift
//  Zephyr
//
//  Created by Eclipse on 14/07/24.
//

import Foundation
import FirebaseAuth

class CurrentUserDataManager {
    public static var shared = CurrentUserDataManager()
    var userData: UserModel?
    private var cachedUser: UserModel?
    
    func clearCachedUser(){
        cachedUser = nil
    }
    public func setCurrentUserData(_ user: UserModel?) {
        if user == nil {
            return
        }
        self.userData = user
        self.cachedUser = user
    }
    public func getCurrentUserData() -> UserModel? {
        return userData
    }
    public func fetchLoggedInUserData(completion: @escaping (UserModel?, Bool) -> Void) {
        if let cachedUser = self.cachedUser {
            completion(cachedUser, true)
            return
        }
        guard let email = Auth.auth().currentUser?.email else {
            completion(nil, false)
            return
        }
        DatabaseManager.shared.fetchUserData(for: email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let userName = user.userName
                let dispatchGroup = DispatchGroup()
                var posts: [String] = []
                var savedPosts: [String] = []
                var followers: [FollowerFollowing] = []
                var following: [FollowerFollowing] = []
                
                dispatchGroup.enter()
                DatabaseManager.shared.getPosts(for: userName){ fetchedPosts in
                    posts = fetchedPosts
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                DatabaseManager.shared.getSavedPosts(for: userName){ fetchedSavedPosts in
                    savedPosts = fetchedSavedPosts
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
                    updatedUser.savedPosts = savedPosts
                    updatedUser.followers = followers
                    updatedUser.following = following
                    updatedUser.counts = updatedCounts
                    self.cachedUser = updatedUser
                    self.userData = updatedUser
                    completion(updatedUser, true)
                }
            case .failure(let error):
                print("Failed to fetch user data: \(error)")
                completion(nil, false)
            }
        }
    }
    
    public func refreshUserData(completion: @escaping (UserModel?, Bool) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            completion(nil, false)
            return
        }
        
        DatabaseManager.shared.fetchUserData(for: email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                let userName = user.userName
                let dispatchGroup = DispatchGroup()
                
                var posts: [String] = []
                var savedPosts: [String] = []
                var followers: [FollowerFollowing] = []
                var following: [FollowerFollowing] = []
                
                dispatchGroup.enter()
                DatabaseManager.shared.getPosts(for: userName){ fetchedPosts in
                    posts = fetchedPosts
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                DatabaseManager.shared.getSavedPosts(for: userName){ fetchedSavedPosts in
                    savedPosts = fetchedSavedPosts
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
                    updatedUser.savedPosts = savedPosts
                    updatedUser.followers = followers
                    updatedUser.following = following
                    updatedUser.counts = updatedCounts
                    self.cachedUser = updatedUser
                    self.userData = updatedUser
                    completion(updatedUser, true)
                }
            case .failure(let error):
                print("Failed to refresh user data: \(error)")
                completion(nil, false)
            }
        }
    }
}
