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
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.addSublayer(playerLayer)
    }
    func configure(with model: UserPost) {
        switch model.postType {
        case .photo:
            postImageView.isHidden = false
            let imageURL = model.postURL
            postImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
        case .video:
            postImageView.isHidden = true
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
    }
}
