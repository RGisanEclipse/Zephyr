//
//  PostGeneralTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

protocol PostGeneralTableViewCellDelegate: AnyObject{
    func didTapCommentLikeButton(with model: PostComment, from: PostGeneralTableViewCell)
    func didTapProfilePictureButton(with userName: String)
    func didTapUserNameButton(with userName: String)
}

class PostGeneralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var userNameLabel: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentLikeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLikesLabel: UILabel!
    
    var isLiked: Bool?
    var delegate: PostGeneralTableViewCellDelegate?
    var model: PostComment?
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: PostComment, userName: String) {
        self.model = model
        profilePictureButton.sd_setImage(with: URL(string: model.profilePicture), for: .normal, placeholderImage: UIImage(systemName: "userPlaceholder"))
        userNameLabel.setTitle(model.userName, for: .normal)
        commentLabel.text = model.text
        dateLabel.text = formattedDateString(from: model.createdDate)
        let isLikedByCurrentUser = model.likes.contains { like in
            like.userName == userName
        }
        if isLikedByCurrentUser {
            commentLikeButton.tintColor = .systemRed
            commentLikeButton.setBackgroundImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            isLiked = true
        } else {
            commentLikeButton.tintColor = UIColor(named: "BW")
            commentLikeButton.setBackgroundImage(UIImage(systemName: "suit.heart"), for: .normal)
            isLiked = false
        }
        commentLikesLabel.text = String(model.likes.count)
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
    @IBAction func commentLikeButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapCommentLikeButton(with: safeModel, from: self)
    }
    
    @IBAction func profilePictureButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapProfilePictureButton(with: safeModel.userName)
    }
    @IBAction func userNameButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapUserNameButton(with: safeModel.userName)
    }
}
