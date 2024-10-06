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
    
    private var representedAssetIdentifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        videoIndicator.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        videoIndicator.isHidden = true
        representedAssetIdentifier = nil
    }

    func configure(with asset: PHAsset, targetSize: CGSize) {
        representedAssetIdentifier = asset.localIdentifier
        
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
        
        let currentAssetIdentifier = asset.localIdentifier

        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFill,
                                              options: options) { [weak self] (image, _) in
            guard let self = self else { return }
            if self.representedAssetIdentifier == currentAssetIdentifier {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }

    private func configureForVideo(with asset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        
        let currentAssetIdentifier = asset.localIdentifier

        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, _) in
            guard let self = self, let avAsset = avAsset as? AVURLAsset else {
                print("Failed to fetch AVAsset for video")
                return
            }
            if self.representedAssetIdentifier == currentAssetIdentifier {
                DispatchQueue.main.async {
                    let generator = AVAssetImageGenerator(asset: avAsset)
                    generator.appliesPreferredTrackTransform = true
                    let time = CMTime(seconds: 0.5, preferredTimescale: 600)
                    
                    // copyCGImage was Deprecated in iOS18
                    
//                    do {
//                        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
//                        let thumbnail = UIImage(cgImage: cgImage)
//                        self.imageView.image = thumbnail
//                    } catch let error {
//                        print("Error generating thumbnail: \(error.localizedDescription)")
//                        self.imageView.image = nil
//                    }
                    
                    generator.generateCGImageAsynchronously(for: time) { cgImage, CMTime, error in

                        if let error = error {
                            print("Error generating thumbnail: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.imageView.image = nil
                            }
                            return
                        }

                        guard let cgImage = cgImage else {
                            print("Failed to generate CGImage")
                            DispatchQueue.main.async {
                                self.imageView.image = nil
                            }
                            return
                        }

                        let thumbnail = UIImage(cgImage: cgImage)
                        DispatchQueue.main.async {
                            self.imageView.image = thumbnail
                        }
                    }
                }
            }
        }
    }
}
