//
//  EmailModel.swift
//  Zephyr
//
//  Created by Eclipse on 28/06/24.
//

import Foundation
struct EmailModel{
    let name: String
    init(name: String) {
        self.name = name
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
                        <h1>Welcome to Zephyr!</h1>
                    </div>
                    <div class="content">
                        <p>Hi \(name),</p>
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
    func getEmailBody() -> String{
        return message
    }
}
