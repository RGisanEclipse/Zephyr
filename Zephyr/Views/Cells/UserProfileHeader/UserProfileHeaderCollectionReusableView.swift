//
//  UserProfileHeaderCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 07/08/24.
//

import UIKit
import SDWebImage
import SkeletonView

protocol UserProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func userProfileHeaderDidTapPostsButton(_ header: UserProfileHeaderCollectionReusableView)
    func userProfileHeaderDidTapFollowersButton(_ header: UserProfileHeaderCollectionReusableView)
    func userProfileHeaderDidTapFollowingButton(_ header: UserProfileHeaderCollectionReusableView)
    func userProfileHeaderDidTapFollowButton(_ header: UserProfileHeaderCollectionReusableView)
}

class UserProfileHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followUnfollowButton: UIButton!
    
    weak var delegate: UserProfileHeaderCollectionReusableViewDelegate?
    var doesFollowProperty: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupProfilePictureButton()
        followUnfollowButton.layer.cornerRadius = CGFloat(8)
        followUnfollowButton.isHidden = true
        setupSkeleton()
    }
    
    private func setupProfilePictureButton() {
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 0.2
        profilePictureButton.layer.borderColor = CGColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.clipsToBounds = true
    }
    
    private func setupSkeleton() {
        isSkeletonable = false
        profilePictureButton.isSkeletonable = true
        nameLabel.isSkeletonable = true
        bioLabel.isSkeletonable = true
        numberOfPostsLabel.isSkeletonable = true
        numberOfFollowersLabel.isSkeletonable = true
        followingLabel.isSkeletonable = true
    }
    func hideSkeletons(){
        nameLabel.hideSkeleton(transition: .crossDissolve(0.25))
        bioLabel.hideSkeleton(transition: .crossDissolve(0.25))
        numberOfPostsLabel.hideSkeleton(transition: .crossDissolve(0.25))
        numberOfFollowersLabel.hideSkeleton(transition: .crossDissolve(0.25))
        followingLabel.hideSkeleton(transition: .crossDissolve(0.25))
    }
    func showSkeletonView() {
        profilePictureButton.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        nameLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        bioLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        numberOfPostsLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        numberOfFollowersLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        followingLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
    }
    func configure(with model: UserModel, doesFollow: Bool){
        profilePictureButton.sd_setImage(with: model.profilePicture, for: .normal, placeholderImage: UIImage(named: "userPlaceholder"), options: [], context: nil, progress: nil) { [weak self] (image, error, cacheType, url) in
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                    self?.profilePictureButton.setImage(UIImage(named: "userPlaceholder"), for: .normal)
                } else {
                    self?.profilePictureButton.setImage(image, for: .normal)
                }
                self?.profilePictureButton.hideSkeleton(transition: .crossDissolve(0.25))
            }
        if let firstName = model.name?.first, let lastName = model.name?.last {
            nameLabel.text = "\(firstName) \(lastName)"
        }
        bioLabel.text = model.bio.isEmpty ? nil : model.bio
        if let counts = model.counts {
            numberOfPostsLabel.text = String(counts.posts)
            numberOfFollowersLabel.text = String(counts.followers)
            followingLabel.text = String(counts.following)
        } else {
            numberOfPostsLabel.text = "0"
            numberOfFollowersLabel.text = "0"
            followingLabel.text = "0"
        }
        if doesFollow == false{
            followUnfollowButton.setTitle("Follow", for: .normal)
            followUnfollowButton.backgroundColor = UIColor(cgColor: CGColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0))
        } else{
            followUnfollowButton.setTitle("Following", for: .normal)
            followUnfollowButton.backgroundColor = UIColor(cgColor: CGColor(red: 0.556, green: 0.556, blue: 0.576, alpha: 1.0))
        }
        followUnfollowButton.isHidden = false
    }
    func calculateHeight() -> CGFloat {
        var height: CGFloat = 0
        height += profilePictureButton.frame.height
        height += nameLabel.frame.height
        height += bioLabel.frame.height
        height += numberOfPostsLabel.frame.height
        height += numberOfFollowersLabel.frame.height
        height += followingLabel.frame.height
        height += followUnfollowButton.frame.height
        return height
    }
    
    @IBAction func postsButtonPressed(_ sender: UIButton) {
        delegate?.userProfileHeaderDidTapPostsButton(self)
    }
    @IBAction func followersButtonPressed(_ sender: UIButton) {
        delegate?.userProfileHeaderDidTapFollowersButton(self)
    }
    @IBAction func followingButtonPressed(_ sender: UIButton) {
        delegate?.userProfileHeaderDidTapFollowingButton(self)
    }
    
    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        delegate?.userProfileHeaderDidTapFollowButton(self)
    }
}
