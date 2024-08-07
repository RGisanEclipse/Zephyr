//
//  StorageManager.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import FirebaseStorage
import Foundation

public class StorageManager{
    static let shared = StorageManager()
    private let bucket = Storage.storage().reference()
    
    public let downloadFailureError = NSError(domain: Constants.Errors.failedToDownload, code: Constants.ErrorCodes.failedToDownload)
    
    func uploadUserPhotoPost(model: UserPost, completion: @escaping(Result< URL,Error >)-> Void){
        
    }
    public func downloadImage(with reference: String, completion: @escaping(Result< URL, Error >)-> Void){
        bucket.child(reference).downloadURL { url, error in
            guard let url = url, error == nil
            else{
                completion(.failure(self.downloadFailureError))
                return
            }
            completion(.success(url))
        }
    }
    public func uploadImage(data: Data, completion: @escaping (URL?) -> Void) {
        let storageRef = bucket.child("images/\(UUID().uuidString).jpg")
        storageRef.putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                completion(url)
            }
        }
    }
        
    public func uploadVideo(fileURL: URL, completion: @escaping (URL?) -> Void) {
        let storageRef = bucket.child("videos/\(UUID().uuidString).mp4")
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            guard error == nil else {
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                completion(url)
            }
        }
    }
    public func deleteImage(reference: String, completion: @escaping (Bool) -> Void) {
        let storageRef = bucket.child(reference)
        storageRef.delete { error in
            completion(error == nil)
        }
    }
    public func deleteMedia(reference: String, isVideo: Bool, completion: @escaping (Bool) -> Void) {
        let mediaType = isVideo ? "videos" : "images"
        let storageRef = bucket.child("\(mediaType)/\(reference)")
        storageRef.delete { error in
            if let error = error {
                print("Error deleting media: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
