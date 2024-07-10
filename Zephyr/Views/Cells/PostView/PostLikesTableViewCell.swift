//
//  PostLikesTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 10/07/24.
//

import UIKit
protocol PostLikesTableViewCellDelegate: AnyObject{
    func didTapLikesButton(with likesData: [PostLike])
}
class PostLikesTableViewCell: UITableViewCell {

    @IBOutlet weak var likesButton: UIButton!
    weak var delegate: PostLikesTableViewCellDelegate?
    var model: [PostLike]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure (with model: [PostLike]){
        likesButton.setTitle("\(model.count) likes", for: .normal)
        self.model = model
    }
    
    @IBAction func likesButtonPressed(_ sender: UIButton) {
        delegate?.didTapLikesButton(with: model ?? [])
    }
}
