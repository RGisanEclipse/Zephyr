//
//  CreatePostViewController.swift
//  Zephyr
//
//  Created by Eclipse on 11/07/24.
//

import UIKit
import Photos

class CreatePostViewController: UIViewController {
    
    var asset: PHAsset?
    private var userData = UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "It's not who you are underneath, it's what you do, that defines you.", name: (first: "Bruce", last: "Wayne"), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 0, following: 0), joinDate: Date(), followers: [], following: [])
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dimmedView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextView.layer.cornerRadius = CGFloat(10)
        captionTextView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        captionTextView.delegate = self
        loadAsset()
        spinner.isHidden = true
        dimmedView.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(dimmedView)
        self.view.bringSubviewToFront(spinner)
    }
    func loadAsset(){
        guard let safeAsset = asset else{
            return
        }
        let targetSize = CGSize(width: imageView.frame.width, height: imageView.frame.height)
        switch safeAsset.mediaType {
        case .image:
            configureForImage(with: safeAsset, targetSize: targetSize)
        case .video:
            configureForVideo(with: safeAsset)
        default:
            break
        }
    }
    
    private func configureForImage(with asset: PHAsset, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFill,
                                              options: options) { [weak self] (image, _) in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
    private func configureForVideo(with asset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, _) in
            guard let self = self, let avAsset = avAsset as? AVURLAsset else {
                print("Failed to fetch AVAsset for video")
                return
            }
            DispatchQueue.main.async {
                let generator = AVAssetImageGenerator(asset: avAsset)
                generator.appliesPreferredTrackTransform = true
                let time = CMTime(seconds: 0.5, preferredTimescale: 600)
                do {
                    let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    self.imageView.image = thumbnail
                } catch let error {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                    self.imageView.image = nil
                }
            }
        }
    }
    @IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
        guard let asset = asset else{
            return
        }
        switch asset.mediaType{
        case .image:
            uploadImageAsset(asset, caption: "")
            break
        case.video:
            uploadVideoAsset(asset, caption: "")
            break
        default:
            break
        }
    }
    private func uploadImageAsset(_ asset: PHAsset, caption: String) {
        spinner.isHidden = false
        dimmedView.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        spinner.startAnimating()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.version = .current

        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [weak self] (imageData, dataUTI, orientation, info) in
            guard let self = self else { return }
            
            if let imageData = imageData {
                if let image = UIImage(data: imageData), let croppedImageData = image.jpegData(compressionQuality: 0.8) {
                    // Upload the cropped image data to Firebase Storage
                    StorageManager.shared.uploadImage(data: croppedImageData) { url in
                        guard let url = url else {
                            print("Failed to upload image")
                            self.spinner.stopAnimating()
                            self.dimmedView.isHidden = true
                            self.navigationController?.setNavigationBarHidden(false, animated: false)
                            return
                        }
                        print("Image uploaded successfully at \(url)")
                        self.spinner.stopAnimating()
                        self.dimmedView.isHidden = true
                        self.navigationController?.setNavigationBarHidden(false, animated: false)
                    }
                } else {
                    print("Failed to process image data")
                    self.spinner.stopAnimating()
                    self.dimmedView.isHidden = true
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                }
            } else {
                print("Failed to get image data: \(String(describing: info))")
                self.spinner.stopAnimating()
                self.dimmedView.isHidden = true
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }
    private func uploadVideoAsset(_ asset: PHAsset, caption: String) {
        spinner.isHidden = false
        dimmedView.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        spinner.startAnimating()
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, _) in
            guard let self = self, let avAsset = avAsset as? AVURLAsset else {
                print("Failed to fetch AVAsset for video")
                self!.spinner.stopAnimating()
                self!.dimmedView.isHidden = true
                self!.navigationController?.setNavigationBarHidden(false, animated: false)
                return
            }
            let videoURL = avAsset.url
            StorageManager.shared.uploadVideo(fileURL: videoURL) { [weak self] url in
                guard let self = self, let url = url else {
                    print("Failed to upload video")
                    self!.spinner.stopAnimating()
                    self!.dimmedView.isHidden = true
                    self!.navigationController?.setNavigationBarHidden(false, animated: false)
                    return
                }
                print("Uploaded video successfully at \(url)")
                let generator = AVAssetImageGenerator(asset: avAsset)
                generator.appliesPreferredTrackTransform = true
                let time = CMTime(seconds: 0.5, preferredTimescale: 600)
                do {
                    let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    StorageManager.shared.uploadImage(data: thumbnail.jpegData(compressionQuality: 0.8)!) { [weak self] thumbnailURL in
                        guard let self = self, let thumbnailURL = thumbnailURL else {
                            print("Failed to upload thumbnail")
                            self!.spinner.stopAnimating()
                            self!.dimmedView.isHidden = true
                            self!.navigationController?.setNavigationBarHidden(false, animated: false)
                            return
                        }
                        print("Uploaded thumbnail successfully! at \(thumbnailURL.absoluteString)")
                        self.spinner.stopAnimating()
                        self.dimmedView.isHidden = true
                        self.navigationController?.setNavigationBarHidden(false, animated: false)
                    }
                } catch let error {
                    print("Error generating thumbnail: \(error.localizedDescription)")
                    self.spinner.stopAnimating()
                    self.dimmedView.isHidden = true
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreatePostViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
}
