//
//  UploadMediaCollectionViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 11/07/24.
//

import UIKit
import Photos

class UploadMediaCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        videoIndicator.isHidden = true
    }
    func configure(with asset: PHAsset, targetSize: CGSize) {
        switch asset.mediaType {
        case .image:
            configureForImage(with: asset, targetSize: targetSize)
            videoIndicator.isHidden = true
        case .video:
            configureForVideo(with: asset)
            videoIndicator.isHidden = false
        default:
            break
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bringSubviewToFront(videoIndicator)
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
