//
//  PostHeaderTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

class PostHeaderTableViewCell: UITableViewCell {

        
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var userNameLabel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: UserModel){
        profilePictureButton.sd_setBackgroundImage(with: model.profilePicture, for: .normal, completed: nil)
        userNameLabel.setTitle(model.userName, for: .normal)
    }
}
