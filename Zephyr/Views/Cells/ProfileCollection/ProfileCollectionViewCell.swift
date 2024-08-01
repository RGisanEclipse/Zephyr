//
//  ProfileCollectionViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 23/06/24.
//

import UIKit
import SDWebImage
class ProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var videoIndicator: UIImageView!
    @IBOutlet weak var cellImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with model: PostSummary){
        let imageURL = model.thumbnailImage
        cellImage.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
        if model.postType == .video{
            videoIndicator.image = UIImage(systemName: "video.fill")
        } else{
            videoIndicator.isHidden = true
        }
    }
}
