//
//  NoPostsYetCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 14/12/24.
//

import UIKit

class NoPostsYetCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(view: String){
        if view == Constants.NoPostsYet.postsView{
            textLabel.text = Constants.NoPostsYet.postsViewLabel
        } else if view == Constants.NoPostsYet.videoPostsView{
            textLabel.text = Constants.NoPostsYet.videoPostsViewLabel
        } else if view == Constants.NoPostsYet.savedPostsView{
            textLabel.text = Constants.NoPostsYet.savedPostsViewLabel
        }
    }
}
