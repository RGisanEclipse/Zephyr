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
        let email = Auth.auth().currentUser?.email ?? ""
        DatabaseManager.shared.fetchUserData(for: email) { result in
            switch result {
            case .success(let user):
                self.userData = user
                completion(user, true)  
            case .failure(let error):
                print("Failed to fetch user data: \(error)")
                completion(nil, false)
            }
        }
    }
}
