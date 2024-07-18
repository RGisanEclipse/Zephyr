//
//  PostHeaderTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit
protocol PostHeaderTableViewCellDelegate: AnyObject{
    func didTapMoreButton()
}
class PostHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var userNameLabel: UIButton!
        
    weak var delegate: PostHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: UserModel){
        profilePictureButton.sd_setImage(with: model.profilePicture, for: .normal, placeholderImage: UIImage(named: "userPlaceholder"))
        userNameLabel.setTitle(model.userName, for: .normal)
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        delegate?.didTapMoreButton()
    }
}
