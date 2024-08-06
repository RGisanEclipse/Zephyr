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
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: PostComment) {
        profilePictureButton.sd_setImage(with: model.user.profilePicture, for: .normal, placeholderImage: UIImage(systemName: "userPlaceholder"))
        userNameLabel.setTitle(model.user.userName, for: .normal)
        commentLabel.text = model.text
        dateLabel.text = formattedDateString(from: model.createdDate)
    }
    private func formattedDateString(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)
        
        if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks)w"
        } else if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}
