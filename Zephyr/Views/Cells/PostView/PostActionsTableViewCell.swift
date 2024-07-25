//
//  PostActionsTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

protocol PostActionsTableViewCellDelegate: AnyObject{
    func didTapLikeButton(with model: UserPost, from: PostActionsTableViewCell, at: IndexPath)
    func didTapCommentButton(with model: UserPost)
    func didTapSaveButton(with model: UserPost)
}

class PostActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: PostActionsTableViewCellDelegate?
    var isLiked: Bool?
    var model: UserPost?
    private var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(with model: UserPost, userName: String, indexPath: IndexPath){
        self.model = model
        self.indexPath = indexPath
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
        delegate?.didTapLikeButton(with: model!, from: self, at: indexPath!)
    }
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        delegate?.didTapCommentButton(with: model!)
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        delegate?.didTapSaveButton(with: model!)
    }
}
