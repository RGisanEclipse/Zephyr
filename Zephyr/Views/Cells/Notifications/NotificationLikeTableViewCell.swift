//
//  NotificationLikeTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 01/07/24.
//

import UIKit
import SDWebImage
protocol NotificationLikeTableViewCellDelegate: AnyObject{
    func didTapProfilePictureButton(with userName: String)
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
        delegate?.didTapProfilePictureButton(with: model.user.userName)
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
        contentLabel.text = "\(model.text) \(formattedTimeAgo(from: model.date))"
        profilePictureButton.sd_setImage(with: model.user.profilePicture, for: .normal, completed: nil)
    }
    private func formattedTimeAgo(from date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
            return "\(secondsAgo)s"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute)m"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour)h"
        } else if secondsAgo < week {
            return "\(secondsAgo / day)d"
        } else {
            let formatter = DateFormatter()
            if Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: Date()) {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "MMM yyyy"
            }
            return formatter.string(from: date)
        }
    }

}
