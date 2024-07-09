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
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: PostComment){
        profilePictureButton.sd_setBackgroundImage(with: model.user.profilePicture, for: .normal, placeholderImage: UIImage(systemName: "person.circle.fill"))
        userNameLabel.setTitle(model.user.userName, for: .normal)
        commentLabel.text = model.text
        commentNumberLabel.text = String(model.likes.count)
    }
}
