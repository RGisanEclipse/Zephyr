//
//  ProfileHeaderCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 30/06/24.
//

import UIKit
import SDWebImage
import SkeletonView

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderDidTapPostsButton(_ header: ProfileHeaderCollectionReusableView)
    func profileHeaderDidTapFollowersButton(_ header: ProfileHeaderCollectionReusableView)
    func profileHeaderDidTapFollowingButton(_ header: ProfileHeaderCollectionReusableView)
    func profileHeaderDidTapEditProfileButton(_ header: ProfileHeaderCollectionReusableView)
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupProfilePictureButton()
        editProfileButton.layer.cornerRadius = CGFloat(8)
        editProfileButton.isEnabled = false
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
    
    func configure(with model: UserModel) {
        hideSkeleton()
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
    }
    func hideSkeletons(){
        nameLabel.hideSkeleton(transition: .crossDissolve(0.25))
        bioLabel.hideSkeleton(transition: .crossDissolve(0.25))
        numberOfPostsLabel.hideSkeleton(transition: .crossDissolve(0.25))
        numberOfFollowersLabel.hideSkeleton(transition: .crossDissolve(0.25))
        followingLabel.hideSkeleton(transition: .crossDissolve(0.25))
        editProfileButton.isEnabled = true
    }
    func showSkeletonView() {
        profilePictureButton.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        nameLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        bioLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        numberOfPostsLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        numberOfFollowersLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        followingLabel.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
    }
    
    @IBAction func postsButtonPressed(_ sender: UIButton) {
        delegate?.profileHeaderDidTapPostsButton(self)
    }
    @IBAction func followersButtonPressed(_ sender: UIButton) {
        delegate?.profileHeaderDidTapFollowersButton(self)
    }
    @IBAction func followingButtonPressed(_ sender: UIButton) {
        delegate?.profileHeaderDidTapFollowingButton(self)
    }
    
    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        delegate?.profileHeaderDidTapEditProfileButton(self)
    }
}
