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
        guard let safeModel = model, let safeIndexPath = indexPath else{
            return
        }
        delegate?.didTapLikeButton(with: safeModel, from: self, at: safeIndexPath)
    }
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapCommentButton(with: safeModel)
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let safeModel = model else{
            return
        }
        delegate?.didTapSaveButton(with: safeModel)
    }
}
