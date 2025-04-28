//
//  AIManager.swift
//  Zephyr
//
//  Created by Eclipse on 25/12/24.
//

import Foundation

class AIManager{
    public static var shared = AIManager()
    func generateTextFromPrompt(inputText: String, completion: @escaping (String?) -> Void) {
        let apiKey = GPT.key
        let baseURL = GPT.url
        let endpoint = "\(baseURL)\(GPT.endpoint)"
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "model": "pai-001-light",
            "messages": [
                ["role": "system", "content": "\(GPT.prompt) \(inputText)"],
                ["role": "user", "content": "\(GPT.prompt) \(inputText)"]
            ]
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON: \(error)")
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                    
                } else {
                    print("Unexpected response format")
                    completion(nil)
                }
            } catch {
                print("Failed to parse JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
