//
//  CommonPasswords.swift
//  Zephyr
//
//  Created by Eclipse on 17/12/24.
//

import Foundation

class PasswordManager {
    private static let commonPasswords = ["123456",
                                   "password",
                                   "12345678",
                                   "qwerty123",
                                   "abc123",
                                   "123456789",
                                   "1234567890",
                                   "password123",
                                   "1234567890",
                                   "qwerty123",
                                   "iloveyou",
                                   "admin1234",
                                   "welcome123",
                                   "abc123456",
                                   "letmein123",
                                   "sunshine123",
                                   "football123",
                                   "monkey1234",
                                   "superman1",
                                   "batman123",
                                   "princess12",
                                   "charlie123",
                                   "hello12345",
                                   "freedom123",
                                   "starwars1",
                                   "dragon123",
                                   "jordan1234",
                                   "passwords123",
                                   "michael123",
                                   "shadow123",
                                   "harley123",
                                   "whatever12",
                                   "spiderman1",
                                   "iloveyou1",
                                   "buster123",
                                   "pepper123",
                                   "lovely1234"]
    public static func getCommonPasswords()-> [String]{
        return commonPasswords
    }
}
