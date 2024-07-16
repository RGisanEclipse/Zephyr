//
//  PostGeneralTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

class PostGeneralTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var userNameLabel: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentLikeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: PostComment){
        profilePictureButton.sd_setImage(with: model.user.profilePicture, for: .normal, placeholderImage: UIImage(systemName: "userPlaceholder"))
        userNameLabel.setTitle(model.user.userName, for: .normal)
        commentLabel.text = model.text
    }
}
