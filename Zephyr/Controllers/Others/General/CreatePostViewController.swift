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
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextView.layer.cornerRadius = CGFloat(10)
        captionTextView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        captionTextView.delegate = self
        loadAsset()
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
