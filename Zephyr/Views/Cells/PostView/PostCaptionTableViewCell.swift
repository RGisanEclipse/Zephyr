//
//  PostCaptionTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 10/07/24.
//

import UIKit

class PostCaptionTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(with caption: String){
        captionLabel.text = caption
    }
    
}
