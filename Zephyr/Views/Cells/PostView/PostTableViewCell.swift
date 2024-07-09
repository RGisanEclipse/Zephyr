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
    
    private var speakerState = "Mute"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.addSublayer(playerLayer)
        speakerButton.isHidden = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func configure(with model: UserPost) {
        switch model.postType {
        case .photo:
            postImageView.isHidden = false
            let imageURL = model.postURL
            postImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
        case .video:
            postImageView.isHidden = true
            speakerButton.isHidden = false
            let url = model.postURL
            player = AVPlayer(url: url)
            playerLayer.player = player
            playerLayer.frame = contentView.bounds
            player?.volume = 0
            player?.play()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
        contentView.bringSubviewToFront(speakerButton)
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
}
