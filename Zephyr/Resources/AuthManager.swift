//
//  AuthManager.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import FirebaseAuth

public class AuthManager{
    static let shared = AuthManager()
    
    // MARK: - Public
    public func registerNewUser(userName: String, email: String, password: String, completion: @escaping (Bool) -> Void){
        DatabaseManager.shared.canCreateNewUser(with: email, userName: userName){ canCreate in
            if canCreate{
                // Create an account and add to database
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil
                    else {
                        // Couldn't create account
                        completion(false)
                        return
                    }
                    DatabaseManager.shared.insertNewUser(with: email, userName: userName) { inserted in
                        if inserted{
                            completion(true)
                            return
                        } else{
                            completion(false)
                            return
                        }
                    }
                }
            } else{
                completion(false)
            }
        }
    }
    public func loginUser(userName: String?, email: String?, password: String, completion: @escaping (Bool) -> Void){
        if let safeEmail = email{
            Auth.auth().signIn(withEmail: safeEmail, password: password) { authResult, error in
                guard authResult != nil, error == nil
                else{
                    completion(false)
                    return
                }
                completion(true)
            }
        }
        else if let safeUserName = userName{
            print(safeUserName)
        }
    }
}
