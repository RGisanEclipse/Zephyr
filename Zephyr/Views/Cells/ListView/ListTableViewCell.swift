//
//  ListTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 25/06/24.
//

import UIKit
protocol UserFollowTableViewCellDelegate: AnyObject {
    func didTapFollowButton(model: UserRelationship, cell: ListTableViewCell)
    func didTapUserNameButton(with userName: String)
    func didTapProfilePictureButton(with userName: String)
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
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
        followButton.layer.cornerRadius = CGFloat(8)
    }
    
    public func configure(with model: UserRelationship) {
        self.model = model
        usernameButton.setTitle(model.username, for: .normal)
        profilePictureButton.sd_setImage(with: URL(string: model.profilePicture ?? ""), for: .normal, placeholderImage: UIImage(named: "userPlaceholder"))
        switch model.type {
        case .following:
            followButton.setTitle("Following", for: .normal)
            followButton.backgroundColor = .systemGray
        case .notFollowing:
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = .link
        }
    }
    @IBAction func profilePictureButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else { return }
        delegate?.didTapProfilePictureButton(with: safeModel.username)
    }
    
    @IBAction func userNameButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else { return }
        delegate?.didTapUserNameButton(with: safeModel.username)
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        guard let model = model else{
            return
        }
        delegate?.didTapFollowButton(model: model, cell: self)
    }
}
