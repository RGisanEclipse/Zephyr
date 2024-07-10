//
//  PostActionsTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

protocol PostActionsTableViewCellDelegate: AnyObject{
    func didTapLikeButton()
    func didTapCommentButton(with model: UserPost)
    func didTapSaveButton()
}

class PostActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: PostActionsTableViewCellDelegate?
    var isLiked: Bool?
    var model: UserPost?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(with model: UserPost, userName: String){
        self.model = model
        let isLikedByCurrentUser = model.likeCount.contains { like in
            like.userName == userName
        }
        if isLikedByCurrentUser {
            likeButton.tintColor = .systemRed
            likeButton.setBackgroundImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            isLiked = true
        } else {
            likeButton.tintColor = UIColor(named: "BW")
            likeButton.setBackgroundImage(UIImage(systemName: "suit.heart"), for: .normal)
            isLiked = false
        }
    }
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        delegate?.didTapLikeButton()
    }
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        delegate?.didTapCommentButton(with: model!)
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        delegate?.didTapSaveButton()
    }
}
