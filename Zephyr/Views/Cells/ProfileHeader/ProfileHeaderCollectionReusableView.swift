//
//  ProfileHeaderCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 30/06/24.
//

import UIKit
import SDWebImage
protocol ProfileHeaderCollectionReusableViewDelegate{
    func profileHeaderDidTapPostsButton(_ header: ProfileHeaderCollectionReusableView)
    func profileHeaderDidTapFollowersButton(_ header: ProfileHeaderCollectionReusableView)
    func profileHeaderDidTapFollowingButton(_ header: ProfileHeaderCollectionReusableView)
}
class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    public var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: UserModel){
        profilePictureButton.sd_setBackgroundImage(with: model.profilePicture, for: .normal, placeholderImage: UIImage(systemName: "person.circle.fill"))
        nameLabel.text = "\(model.name.first) \(model.name.last)"
        bioLabel.text = model.bio
        numberOfPostsLabel.text = String(model.counts.posts)
        numberOfFollowersLabel.text = String(model.counts.followers)
        followingLabel.text = String(model.counts.following)
    }
    @IBAction func postsButtonPressed(_ sender: UIButton) {
        delegate?.profileHeaderDidTapPostsButton(self)
    }
    @IBAction func followersButtonPressed(_ sender: UIButton){
        delegate?.profileHeaderDidTapFollowersButton(self)
    }
    @IBAction func followingButtonPressed(_ sender: UIButton){
        delegate?.profileHeaderDidTapFollowingButton(self)
    }
}
