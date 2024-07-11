//
//  UploadMediaViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
import Photos

class UploadMediaViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    private var assets = [PHAsset]()
    private let imageManager = PHCachingImageManager()
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkGalleryPermission()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: Constants.UploadMedia.collectionCellIdentifier, bundle: nil), forCellWithReuseIdentifier: Constants.UploadMedia.collectionCellIdentifier)
        imageView.image = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer?.pause()
        avPlayerLayer?.removeFromSuperlayer()
    }
    
    func checkGalleryPermission() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .denied:
            showAlertForSettings()
        case .authorized, .limited:
            fetchMedia()
        case .restricted:
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        self.fetchMedia()
                    }
                } else {
                    print("Permission not granted")
                }
            }
        @unknown default:
            break
        }
    }

    func showAlertForSettings() {
        let alert = UIAlertController(title: "Photo library access is denied", message: "Click on settings and give access to photos", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        present(alert, animated: true, completion: nil)
    }

    func fetchMedia() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: fetchOptions)
        self.assets.removeAll()
        result.enumerateObjects { asset, _, _ in
            if asset.mediaType == .image || asset.mediaType == .video {
                self.assets.append(asset)
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UploadMediaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        return CGSize(width: collectionViewWidth/3 - 1, height: collectionViewWidth/3 - 1)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

// MARK: - UICollectionViewDataSource
extension UploadMediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.UploadMedia.collectionCellIdentifier, for: indexPath) as! UploadMediaCollectionViewCell
        let asset = assets[indexPath.item]
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = collectionViewWidth / 3 - 1
        let targetSize = CGSize(width: cellWidth, height: cellWidth)
        cell.configure(with: asset, targetSize: targetSize)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension UploadMediaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = assets[indexPath.item]
        
        if selectedAsset.mediaType == .image {
            self.imageManager.requestImage(for: selectedAsset, targetSize: CGSize(width: imageView.bounds.width, height: imageView.bounds.height), contentMode: .aspectFill, options: nil) { image, _ in
                self.imageView.image = image
            }
            self.avPlayer?.pause()
            self.avPlayerLayer?.removeFromSuperlayer()
            self.avPlayer = nil
            
        } else if selectedAsset.mediaType == .video {
            self.imageView.image = nil
            PHCachingImageManager().requestAVAsset(forVideo: selectedAsset, options: nil) { avAsset, _, _ in
                DispatchQueue.main.async {
                    self.avPlayer?.pause()
                    self.avPlayerLayer?.removeFromSuperlayer()
                    self.avPlayer = AVPlayer(playerItem: AVPlayerItem(asset: avAsset!))
                    let reducedHeight = self.mediaView.bounds.height - 30
                    self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
                    self.avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: self.mediaView.bounds.width, height: reducedHeight)
                    self.avPlayerLayer?.videoGravity = .resizeAspect
                    self.mediaView.layer.addSublayer(self.avPlayerLayer!)
                    self.avPlayer?.play()
                }
            }
        }
    }
}
