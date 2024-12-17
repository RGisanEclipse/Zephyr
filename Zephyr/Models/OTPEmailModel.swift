//
//  OTPModel.swift
//  Zephyr
//
//  Created by Eclipse on 17/12/24.
//

import Foundation

struct OTPEmailModel{
    let OTP: String
    let name: String
    let action: String
    let emailAction: String
    init(OTP: String, name: String, action: String) {
        self.OTP = OTP
        self.name = name
        self.action = action
        if action == Constants.OTP.verifyEmail {
            emailAction = "create a new account"
        } else if action == Constants.OTP.resetPassword {
            emailAction = "reset your account password"
        } else {
            emailAction = "Unknown action"
        }
    }
    var message: String{ """
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
                        <h1>Do not share this email or OTP with anyone.</h1>
                    </div>
                    <div class="content">
                        <p>Hi \(name),</p>
                        <p>We’ve received a request to \(emailAction). For your safety, we’ve generated a One-Time Password (OTP) to confirm your request.</p>
                        <h3>Your OTP is: \(OTP)</h3>
                        <p>This is a 4-digit code that will be valid for the next 5 minutes. Please use it immediately to complete your action.</p>
                        <h3>What to do next:</h3>
                        <p>1. Enter the 4-digit OTP in the app.</p>
                        <p>2. If you didn’t request this action, please disregard this email.</p>
                        <h3>Need Help?</h3>
                        <p>If you need further assistance or have any questions, feel free to contact our support team at rishab28guleria@gmail.com. We're here to help!</p><p><b>Thank you for using Zephyr!</b></p>
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
    func getEmailBody() -> String{
        return message
    }
}
