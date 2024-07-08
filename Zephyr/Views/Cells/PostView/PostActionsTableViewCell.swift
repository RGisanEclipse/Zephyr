//
//  PostActionsTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

protocol PostActionsTableViewCellDelegate: AnyObject{
    func didTapLikeButton()
    func didTapCommentButton()
    func didTapSaveButton()
}

class PostActionsTableViewCell: UITableViewCell {

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: PostActionsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        delegate?.didTapLikeButton()
    }
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        delegate?.didTapCommentButton()
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        delegate?.didTapSaveButton()
    }
}
