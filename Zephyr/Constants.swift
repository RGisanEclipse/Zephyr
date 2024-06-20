//
//  Constants.swift
//  Zephyr
//
//  Created by Eclipse on 19/06/24.
//

import Foundation
struct Constants{
    static let settingsSegue = "toSettingsView"
    struct Onboarding{
        static let registerSegue = "toRegisterView"
        static let emptyError = "Fields cannot be empty"
        static let invalidError = "Invalid Username or Email"
        static let wrongPasswordError = "Wrong Password"
        static let smallPasswordError = "Password must be 8 characters or more"
    }
    struct FireStore{
        static let users = "users"
        static let userName = "userName"
        static let email = "email"
    }
}
