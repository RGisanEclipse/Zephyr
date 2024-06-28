//
//  ListTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 25/06/24.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.width/2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
}
