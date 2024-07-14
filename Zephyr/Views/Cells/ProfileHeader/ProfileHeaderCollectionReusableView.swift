//
//  ProfileHeaderCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 30/06/24.
//

import UIKit
import SDWebImage
protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject{
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
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = CGFloat(0.2)
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: UserModel){
        print("Setting up ProfileHeader with \(model)")
        profilePictureButton.sd_setBackgroundImage(with: model.profilePicture, for: .normal, placeholderImage: UIImage(systemName: "person.circle.fill"))
        if model.name?.first != "", model.name?.last != ""{
            nameLabel.text = "\(model.name?.first ?? "") \(model.name?.last ?? "")"
        }
        if model.bio != ""{
            bioLabel.text = model.bio
        }
        if let counts = model.counts {
            numberOfPostsLabel.text = String(counts.posts)
            numberOfFollowersLabel.text = String(counts.followers)
            followingLabel.text = String(counts.following)
        } else {
            numberOfPostsLabel.text = "0"
            numberOfFollowersLabel.text = "0"
            followingLabel.text = "0"
        }
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
