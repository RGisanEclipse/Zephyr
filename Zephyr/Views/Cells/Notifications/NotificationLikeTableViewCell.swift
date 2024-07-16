//
//  NotificationLikeTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 01/07/24.
//

import UIKit
import SDWebImage
protocol NotificationLikeTableViewCellDelegate: AnyObject{
    func didTapProfilePictureButton(with model: UserNotificationModel)
    func didTapPostButton(with model: UserNotificationModel)
}
class NotificationLikeTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    
    weak var delegate: NotificationLikeTableViewCellDelegate?
    private var model: UserNotificationModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.masksToBounds = true
        postButton.layer.cornerRadius = CGFloat(10)
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        postButton.imageView?.contentMode = .scaleAspectFill
        postButton.layer.masksToBounds = true
    }
    @IBAction func profilePictureButtonTapped(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapProfilePictureButton(with: model)
    }
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapPostButton(with: model)
    }
    func configure(with model: UserNotificationModel){
        self.model = model
        switch model.type{
        case.like(let post):
            let thumbnailImage = post.thumbnailImage
            postButton.sd_setImage(with: thumbnailImage, for: .normal, placeholderImage: UIImage(named: "placeholder"))
        case.follow:
            break
        }
        contentLabel.text = model.text
        profilePictureButton.sd_setImage(with: model.user.profilePicture, for: .normal, completed: nil)
    }
}
