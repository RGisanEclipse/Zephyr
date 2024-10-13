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
        let mainText = "\(model.text)  "
        let timeAgo = formattedTimeAgo(from: model.date)
        let attributedMainText = NSAttributedString(string: mainText, attributes: [
            .foregroundColor: UIColor.label
        ])
        let attributedDateText = NSAttributedString(string: timeAgo, attributes: [
            .foregroundColor: UIColor.systemGray
        ])
        let finalAttributedText = NSMutableAttributedString()
        finalAttributedText.append(attributedMainText)
        finalAttributedText.append(attributedDateText)
        contentLabel.attributedText = finalAttributedText
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
