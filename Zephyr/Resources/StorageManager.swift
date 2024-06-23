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
}
