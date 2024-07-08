//
//  PostTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with model: UserPost){
        let imageURL = model.thumbnailImage
        postImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
    }
}
