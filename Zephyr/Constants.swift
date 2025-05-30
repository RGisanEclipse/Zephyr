//
//  Constants.swift
//  Zephyr
//
//  Created by Eclipse on 19/06/24.
//

import Foundation
struct Constants{
    static let empty = ""
    static let CurrentAppVersion = "Zephyr Version 1.0"
    struct Onboarding{
        static let registerSegue = "toRegisterView"
        static let launchLoginSegue = "toLoginVC"
        static let launchHomeSegue = "toMainVC"
        static let emptyError = "Fields cannot be empty"
        static let invalidError = "Invalid Credentials"
        static let wrongPasswordError = "Wrong Password"
        static let smallPasswordError = "Password must be 8 characters or more"
        static let sucessEmailSubject = "Thanks for registering to Zephyr"
        static let OTPEmailSubject = "One Time Password for Zephyr"
        static let otpSegueLogin = "loginToOTPSegue"
        static let otpSegueRegister = "registerToOTPSegue"
        static let passwordMismatchError = "Passwords don't match"
        static let largePasswordError = "Passwords exceed characters limit"
        static let noUppercaseError = "There are no uppercase characters in the password"
        static let noLowercaseError = "There are no lowercase characters in the password"
        static let noNumberError = "There is no number in the password"
        static let noSpecialCharacterError = "There is no special character in the password"
        static let repeatedCharacterError = "Too many repeated characters in the password"
        static let commonPasswordError = "Your password is too easy to guess"
        static let containsWhitespaceError = "Your password contains whitespaces"
        static let successfulPasswordChange = "Your password changed successfully"
    }
    struct FireStore{
        static let users = "users"
        static let userName = "userName"
        static let email = "email"
        static let posts = "posts"
        static let followers = "followers"
        static let following = "following"
        static let joinDate = "joinDate"
        static let bio = "bio"
        static let gender = "gender"
    }
    struct Settings{
        static let cellIdentifier = "SettingsSimpleTableViewCell"
        static let logoutTitle = "Logout"
        static let logoutMessage = "Are you sure you want to log out?"
        static let toEditProfile = "toEditProfileVC"
        static let toggleTableViewCellIdentifier = "ToggleTableViewCell"
        static let SimpleType = "SimpleCell"
        static let ToggleType = "ToggleCell"
        struct EditProfile{
            static let cellIdentifier = "editProfileTableViewCell"
            static let cellNibName = "FormTableViewCell"
            static let editProfilePictureTitle = "Profile Picture"
            static let editProfilePictureMessage = "Change Profile Picture"
            static let bioCell = "BioTableViewCell"
            static let genderCell = "GenderTableViewCell"
        }
    }
    struct Profile{
        static let cellIdentifier = "profileCVCell"
        static let cellNibName = "ProfileCollectionViewCell"
        static let followersSegue = "toFollowersVC"
        static let followingSegue = "toFollowingVC"
        static let headerIdentifier = "ProfileHeaderCollectionReusableView"
        static let tabsIdentifier = "ProfileTabsCollectionReusableView"
        static let userProfileTabsIdentifier = "ViewUserProfileTabsCollectionReusableView"
        static let postSegue = "profileToPostVC"
        static let settingsSegue = "toSettingsView"
        static let editProfileSegue = "toEditProfileView"
        static let noPostsYetIdentifier = "NoPostsYetCollectionReusableView"
    }
    struct Errors{
        static let emailAlreadyInUse = "Email already in use"
        static let userNameAlreadyExists = "Username taken"
        static let emailDoesntExist = "Email doesn't exist"
        static let failedToDownload = "Failed to download image"
        static let noResponseFromAI = "No response from AI, please try again after sometime"
    }
    struct ErrorCodes{
        static let emailAlreadyInUse = 401
        static let userNameAlreadyExists = 402
        static let emailDoesntExist = 403
        static let failedToDownload = 404
    }
    struct List{
        static let cellIdentifier = "ListTableViewCell"
        static let cellNibName = "ListTableViewCell"
        static let userProfileVC = "listToUserProfileVC"
    }
    struct Notifications{
        static let likeCellIdentifier = "NotificationLikeTableViewCell"
        static let followCellIdentifier = "NotificationFollowTableViewCell"
        static let cellIdentifier = "NotificationsCellIdentifier"
        static let postSegue = "notificationToPostVC"
        static let userProfileSegue = "notificationToUserProfileVC"
    }
    struct Explore{
        static let postSegue = "exploreToPostVC"
        static let userProfileSegue = "exploreToUserProfileVC"
    }
    struct Post{
        static let cellIdentifier = "postTableViewReusableCell"
        static let headerCellIdentifier = "PostHeaderTableViewCell"
        static let postCellIdentifier = "PostTableViewCell"
        static let actionsCellIdentifier = "PostActionsTableViewCell"
        static let likesCellIdentifier = "PostLikesTableViewCell"
        static let generalCellIdentifier = "PostGeneralTableViewCell"
        static let likesSegue = "postToLikesView"
        static let captionCellIdentifier = "PostCaptionTableViewCell"
        static let commentsSegue = "postToCommentsVC"
        static let commentsHeaderCellIdentifier = "CommentsHeaderTableViewCell"
        static let userProfileSegue = "postToUserProfileVC"
    }
    struct Home{
        static let logoCellIdentifier = "HomeLogoTableViewCell"
        static let likesSegue = "homeToLikesView"
        static let postSegue = "homeToPostVC"
        static let commentsCellIdentifier = "HomeCommentsTableViewCell"
        static let commentsSegue = "homeToCommentsVC"
        static let userProfileSegue = "homeToUserProfileVC"
    }
    struct UploadMedia{
        static let collectionCellIdentifier = "UploadMediaCollectionViewCell"
        static let captionSegue = "createPostToCaptionSegue"
    }
    struct Comments{
        static let userProfileSegue = "commentsToUserProfileVC"
    }
    struct UserProfile{
        static let cellNibName = "UserProfileCollectionViewCell"
        static let headerIdentifier = "UserProfileHeaderCollectionReusableView"
        static let postSegue = "userProfileToPostVC"
        static let followersSegue = "userProfileToFollowersVC"
        static let followingSegue = "userProfileToFollowingVC"
        static let editProfileSegue = "userProfileToEditProfileView"
    }
    struct SearchResult{
        static let cellNibName = "SearchResultTableViewCell"
    }
    struct NoPostsYet{
        static let postsView = "postsView"
        static let videoPostsView = "videoPostsView"
        static let savedPostsView = "savedPostsView"
        static let postsViewLabel = "No Posts Yet"
        static let videoPostsViewLabel = "No Video Posts Yet"
        static let savedPostsViewLabel = "No Saved Posts Yet"
    }
    struct OTP{
        static let resetPassword = "forgotPassword"
        static let verifyEmail = "verifyEmail"
        static let resetPasswordText = "We've sent a 4-digit OTP to your email. The OTP is valid for 5 minutes. Please check your inbox and enter the code to reset your password."
        static let resendOTPText = "We've re-sent a 4-digit OTP to your email. The OTP is valid for 5 minutes. Please check your inbox and enter the code to reset your password."
    }
    struct CreatePost{
       static let captionPlaceHolderText = "Write a caption or tap the Magic Button after writing a prompt to generate a caption that’s effortlessly creative and uniquely yours!"
    }
}
