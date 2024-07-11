//
//  CommentsHeaderTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 11/07/24.
//

import UIKit

protocol CommentsHeaderTableViewCellDelegate: AnyObject{
    func didTapPostButton()
}

class CommentsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    weak var delegate: CommentsHeaderTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postButton.layer.cornerRadius = CGFloat(10)
        postButton.layer.masksToBounds = true
    }
    @IBAction func postButtonPressed(_ sender: UIButton) {
        delegate?.didTapPostButton()
    }
    func configure(with model: UserPost){
        headerLabel.text = "Comments on \(model.owner.userName)'s post"
        postButton.sd_setBackgroundImage(with: model.thumbnailImage, for: .normal, placeholderImage: UIImage(named: "placeholder"))
    }
}
