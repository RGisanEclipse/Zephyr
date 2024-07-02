//
//  NotificationsFollowTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 02/07/24.
//

import UIKit
protocol NotificationFollowTableViewCellDelegate: AnyObject{
    func didTapProfilePictureButton(with: UserNotification)
    func didTapFollowButton(with: UserNotification)
}
class NotificationFollowTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate: NotificationFollowTableViewCellDelegate?
    private var model: UserNotification?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    
    @IBAction func profilePictureButtonTapped(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapProfilePictureButton(with: model)
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapFollowButton(with: model)
    }
    func configure(with model: UserNotification){
        self.model = model
        contentLabel.text = model.text
        profilePictureButton.sd_setBackgroundImage(with: model.user.profilePicture, for: .normal, completed: nil)
    }
}
