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
        static let sucessEmailSubject = "Thanks for registering to Zephyr"
        static let successEmailBody = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        line-height: 1.6;
                        color: #333333;
                    }
                    .container {
                        width: 100%;
                        max-width: 600px;
                        margin: 0 auto;
                        padding: 20px;
                        border: 1px solid #dddddd;
                        border-radius: 5px;
                        background-color: #f9f9f9;
                    }
                    .header {
                        text-align: center;
                        padding-bottom: 20px;
                    }
                    .header img {
                        max-width: 100px;
                    }
                    .content {
                        text-align: center;
                    }
                    .footer {
                        text-align: center;
                        padding-top: 20px;
                        font-size: 0.9em;
                        color: #777777;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>Welcome to Zephyr!</h1>
                    </div>
                    <div class="content">
                        <p>Hi there,</p>
                        <p>Thank you for registering for Zephyr. We're excited to have you on board!</p>
                        <p>If you have any questions or need assistance, feel free to reach out to our support team.</p>
                        <p>Best regards,<br>The Zephyr Team</p>
                    </div>
                    <div class="footer">
                        <p>&copy; 2024 Zephyr. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>
            """
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
        struct EditProfile{
            static let cellIdentifier = "editProfileTableViewCell"
            static let cellNibName = "FormTableViewCell"
            static let editProfilePictureTitle = "Profile Picture"
            static let editProfilePictureMessage = "Change Profile Picture"
        }
    }
    struct Profile{
        static let cellIdentifier = "profileCVCell"
        static let cellNibName = "ProfileCollectionViewCell"
        static let followersSegue = "toFollowersVC"
        static let followingSegue = "toFollowingVC"
    }
    struct Errors{
        static let emailAlreadyInUse = "Email already in use"
        static let userNameAlreadyExists = "Username taken"
        static let emailDoesntExist = "Email doesn't exist"
        static let failedToDownload = "Failed to download image"
    }
    struct ErrorCodes{
        static let emailAlreadyInUse = 401
        static let userNameAlreadyExists = 402
        static let emailDoesntExist = 403
        static let failedToDownload = 404
    }
    struct List{
        static let cellIdentifier = "listViewCell"
        static let cellNibName = "ListTableViewCell"
    }
}
