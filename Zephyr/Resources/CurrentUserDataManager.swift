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
    
    public func fetchLoggedInUserData(completion: @escaping (UserModel?, Bool) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            completion(nil, false)
            return
        }
        
        DatabaseManager.shared.fetchUserData(for: email) { result in
            switch result {
            case .success(let user):
                let userName = user.userName
                let dispatchGroup = DispatchGroup()
                
                var followers: [String] = []
                var following: [String] = []
                
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
                    let updatedCounts = UserCount(posts: user.counts?.posts ?? 0, followers: followers.count, following: following.count)
                    var updatedUser = user
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
