//
//  ListTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 25/06/24.
//

import UIKit
protocol UserFollowTableViewCellDelegate: AnyObject {
    func didTapFollowButton(model: UserRelationship)
}

enum FollowState {
    case following, notFollowing
}

struct UserRelationship {
    let username: String
    var type: FollowState
}

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var model: UserRelationship?
    weak var delegate: UserFollowTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.width / 2
//        followButton.layer.cornerRadius = followButton.frame.width / 7
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapFollowButton(model: model)
    }
    
    public func configure(with model: UserRelationship) {
        self.model = model
        usernameButton.setTitle(model.username, for: .normal)
        switch model.type {
        case .following:
            followButton.setTitle("Unfollow", for: .normal)
            followButton.tintColor = .systemGray
        case .notFollowing:
            followButton.setTitle("Follow", for: .normal)
            followButton.tintColor = .link
        }
    }
}
