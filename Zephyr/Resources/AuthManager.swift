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
    public func registerNewUser(userName: String, email: String, password: String, completion: @escaping (Bool, Error?) -> Void){
        DatabaseManager.shared.canCreateNewUser(with: email, userName: userName){ canCreate, error in
            if canCreate{
                // Create an account and add to database
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil
                    else {
                        // Couldn't create account
                        completion(false,error)
                        return
                    }
                    DatabaseManager.shared.insertNewUser(with: email, userName: userName) { inserted in
                        if inserted{
                            let EmailModel = EmailModel(name: userName)
                            BrevoManager.shared.sendEmail(to: email, subject: Constants.Onboarding.sucessEmailSubject, body: EmailModel.getEmailBody()) { result in
                                switch result {
                                    case .success():
                                        print("Email sent successfully!")
                                    case .failure(let error):
                                        print("Error sending email: \(error.localizedDescription)")
                                }
                            }
                            completion(true, error)
                            return
                        } else{
                            completion(false, error)
                            return
                        }
                    }
                }
            } else{
                completion(false, error!)
            }
        }
    }
    public func loginUser(userName: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        if let safeEmail = email {
            Auth.auth().signIn(withEmail: safeEmail, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                CurrentUserDataManager.shared.fetchLoggedInUserData { (user, success) in
                    completion(success)
                }
            }
        } else if let safeUserName = userName {
            DatabaseManager.shared.getEmail(for: safeUserName) { email in
                if let safeEmail = email {
                    Auth.auth().signIn(withEmail: safeEmail, password: password) { authResult, error in
                        guard authResult != nil, error == nil else {
                            completion(false)
                            return
                        }
                        CurrentUserDataManager.shared.fetchLoggedInUserData { (user, success) in
                            completion(success)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    public func logOutUser(completion: (Bool)->Void){
        do{
            try Auth.auth().signOut()
            completion(true)
            return
        } catch{
            completion(false)
            return
        }
    }
    public func forgotPassword(userName: String?, email: String?, completion: @escaping (Bool, String?, String?, String?) -> Void) {
        let otp = String(format: "%04d", Int.random(in: 1000...9999))
        
        if let safeEmail = email {
            DatabaseManager.shared.checkIfEmailExists(email: safeEmail) { exists in
                if exists {
                    DatabaseManager.shared.getUserName(for: safeEmail) { name in
                        if let name {
                            let otpEmailModel = OTPEmailModel(OTP: otp, name: name, action: Constants.OTP.resetPassword)
                            BrevoManager.shared.sendEmail(to: safeEmail, subject: Constants.Onboarding.OTPEmailSubject, body: otpEmailModel.getEmailBody()) { result in
                                switch result {
                                case .success():
                                    print("OTP email sent successfully!")
                                    completion(true, otp, nil, safeEmail)
                                case .failure(let error):
                                    print("Failed to send OTP email: \(error.localizedDescription)")
                                    completion(false, nil, "Error sending email", nil)
                                }
                            }
                        } else{
                            print("No username found for email")
                            completion(false, nil, "No user found with the credentials", nil)
                        }
                    }
                } else {
                    print("Email not found in the database.")
                    completion(false, nil, "No user found with the credentials", nil)
                }
            }
        } else if let safeUserName = userName {
            DatabaseManager.shared.getEmail(for: safeUserName) { fetchedEmail in
                if let email = fetchedEmail {
                    self.forgotPassword(userName: nil, email: email, completion: completion)
                } else {
                    print("Username not found.")
                    completion(false, nil, "No user found with the credentials", nil)
                }
            }
        } else {
            // Shouldn't ideally get called
            print("No email or username provided.")
            completion(false, nil, "No email or username provided", nil)
        }
    }
    public func sendPasswordResetEmail(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print("Reset Password Email has been sent successfully")
                completion(true, nil)
            }
        }
    }
}
