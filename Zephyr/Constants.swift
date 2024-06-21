//
//  Constants.swift
//  Zephyr
//
//  Created by Eclipse on 19/06/24.
//

import Foundation
struct Constants{
    static let settingsSegue = "toSettingsView"
    static let empty = ""
    struct Onboarding{
        static let registerSegue = "toRegisterView"
        static let launchLoginSegue = "toLoginVC"
        static let launchHomeSegue = "toMainVC"
        static let emptyError = "Fields cannot be empty"
        static let invalidError = "Invalid Credentials"
        static let wrongPasswordError = "Wrong Password"
        static let smallPasswordError = "Password must be 8 characters or more"
    }
    struct FireStore{
        static let users = "users"
        static let userName = "userName"
        static let email = "email"
    }
    struct Settings{
        static let cellIdentifier = "settingsOptions"
        static let logoutTitle = "Logout"
        static let logoutMessage = "Are you sure you want to log out?"
        static let toEditProfile = "toEditProfileVC"
    }
    struct Errors{
        static let emailAlreadyInUse = "Email already in use"
        static let userNameAlreadyExists = "Username taken"
        static let emailDoesntExist = "Email doesn't exist"
    }
    struct ErrorCodes{
        static let emailAlreadyInUse = 401
        static let userNameAlreadyExists = 402
        static let emailDoesntExist = 403
    }
}
