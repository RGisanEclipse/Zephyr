//
//  NotificationsFollowTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 02/07/24.
//

import UIKit
protocol NotificationFollowTableViewCellDelegate: AnyObject{
    func didTapProfilePictureButtonF(with userName: String)
    func didTapFollowButton(with model: UserNotificationModel, cell: NotificationFollowTableViewCell)
}
class NotificationFollowTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate: NotificationFollowTableViewCellDelegate?
    private var model: UserNotificationModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.masksToBounds = true
        followButton.layer.cornerRadius = CGFloat(8)
    }
    
    @IBAction func profilePictureButtonTapped(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapProfilePictureButtonF(with: model.user.userName)
    }
    
    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapFollowButton(with: model, cell: self)
    }
    func configure(with model: UserNotificationModel){
        self.model = model
        contentLabel.text = model.text
        profilePictureButton.sd_setBackgroundImage(with: model.user.profilePicture, for: .normal, completed: nil)
        switch model.type{
        case .like(post: _):
            break
        case .follow(let state):
            switch state{
            case .following:
                followButton.setTitle("Following", for: .normal)
                followButton.backgroundColor = .lightGray
            case .notFollowing:
                followButton.setTitle("Follow", for: .normal)
                followButton.backgroundColor = .link
            }
        }
    }
}
