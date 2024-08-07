//
//  PostHeaderTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit
protocol PostHeaderTableViewCellDelegate: AnyObject{
    func didTapMoreButton(for post: UserPost)
    func didTapUserNameButton(with userName: String)
    func didTapProfilePictureButton(with userName: String)
}
class PostHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var userNameLabel: UIButton!
        
    var model: UserPost?
    weak var delegate: PostHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.imageView?.contentMode = .scaleAspectFill
        profilePictureButton.layer.masksToBounds = true
    }
    func configure(with model: UserPost){
        self.model = model
        profilePictureButton.sd_setImage(with: model.owner.profilePicture, for: .normal, placeholderImage: UIImage(named: "userPlaceholder"))
        userNameLabel.setTitle(model.owner.userName, for: .normal)
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapMoreButton(for: safeModel)
    }
    @IBAction func profilePictureButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapProfilePictureButton(with: safeModel.owner.userName)
    }
    
    @IBAction func userNameButtonPressed(_ sender: Any) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapUserNameButton(with: safeModel.owner.userName)
    }
}
