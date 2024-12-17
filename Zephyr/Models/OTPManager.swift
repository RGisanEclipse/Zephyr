//
//  OTPManager.swift
//  Zephyr
//
//  Created by Eclipse on 17/12/24.
//

import Foundation

public class OTPManager{
    static let shared = OTPManager()
    
    public func sendOTP(to email: String, completion: @escaping (Bool, String?, String?) -> Void){
        
        let otp = String(format: "%04d", Int.random(in: 1000...9999))
        DatabaseManager.shared.getUserName(for: email) { name in
            if let name {
                let otpEmailModel = OTPEmailModel(OTP: otp, name: name, action: Constants.OTP.resetPassword)
                BrevoManager.shared.sendEmail(to: email, subject: Constants.Onboarding.OTPEmailSubject, body: otpEmailModel.getEmailBody()) { result in
                    switch result {
                    case .success():
                        print("OTP email sent successfully!")
                        completion(true, otp, nil)
                    case .failure(let error):
                        print("Failed to send OTP email: \(error.localizedDescription)")
                        completion(false, nil, "Error sending email")
                    }
                }
            } else{
                // Shouldn't get called
                print("No username found for email")
                completion(false, nil, "No user found")
            }
        }
    }
}
