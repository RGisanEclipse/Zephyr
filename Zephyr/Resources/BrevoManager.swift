//
//  BrevoManager.swift
//  Zephyr
//
//  Created by Eclipse on 26/06/24.
//

import Foundation

struct BrevoManager {
    static let shared = BrevoManager()
    let apiKey = ""
    let apiURL = ""
    let senderEmail = ""
    
    func sendEmail(to recipientEmail: String, subject: String, body: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let emailData: [String: Any] = [
            "sender": ["email": senderEmail],
            "to": [["email": recipientEmail]],
            "subject": subject,
            "htmlContent": "<html><body>\(body)</body></html>"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: emailData, options: []) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize email data to JSON"])))
            return
        }
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            if httpResponse.statusCode == 201 {
                completion(.success(()))
            } else {
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    let errorDescription = "Failed to send email: \(httpResponse.statusCode), Response body: \(responseBody)"
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                } else {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to send email: \(httpResponse.statusCode), No response body"])))
                }
            }
        }
        task.resume()
    }
}
