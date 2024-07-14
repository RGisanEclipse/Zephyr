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
    public func fetchLoggedInUserData(completion: @escaping (Bool) -> Void) {
        let userName = Auth.auth().currentUser?.displayName ?? ""
        DatabaseManager.shared.fetchUserData(for: userName) { result in
            switch result {
            case .success(let user):
                self.userData = user
                completion(true)
            case .failure(let error):
                print("Failed to fetch user data: \(error)")
                completion(false)
            }
        }
    }
}

