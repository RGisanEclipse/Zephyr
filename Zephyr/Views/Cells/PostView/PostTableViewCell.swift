//
//  PostTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit
import AVFoundation
class PostTableViewCell: UITableViewCell {
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var speakerState = "Mute"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.addSublayer(playerLayer)
        speakerButton.isHidden = true
        spinner.isHidden = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func configure(with model: UserPost) {
        switch model.postType {
        case .photo:
            configurePhoto(with: model.postURL)
        case .video:
            configureVideo(with: model.postURL)
        }
    }

    private func configurePhoto(with url: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.isHidden = true
            self?.postImageView.isHidden = false
            self?.postImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }

    private func configureVideo(with url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let player = AVPlayer(url: url)
            DispatchQueue.main.async {
                self.spinner.startAnimating()
                self.player = player
                self.postImageView.isHidden = true
                self.speakerButton.isHidden = false
                self.playerLayer.player = player
                self.playerLayer.frame = self.contentView.bounds
                self.player?.volume = 0
                self.player?.play()
                self.player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
        contentView.bringSubviewToFront(speakerButton)
        contentView.bringSubviewToFront(spinner)
    }
    
    @IBAction func speakerButtonPressed(_ sender: UIButton) {
        if speakerState == "Mute"{
            unMuteVideo()
        } else{
            muteVideo()
        }
    }
    func pauseVideo() {
        player?.pause()
    }
    func playVideo() {
        player?.play()
    }
    func muteVideo(){
        player?.volume = 0
        speakerState = "Mute"
        speakerButton.setBackgroundImage(UIImage(systemName: "speaker.slash.circle.fill"), for: .normal)
    }
    func unMuteVideo(){
        player?.volume = 1.0
        speakerState = "UnMute"
        speakerButton.setBackgroundImage(UIImage(systemName: "speaker.circle.fill"), for: .normal)
    }
    override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let player = object as? AVPlayer,
           player == self.player,
           player.status == .readyToPlay {
            spinner.stopAnimating()
            player.removeObserver(self, forKeyPath: "status")
        }
    }
}
