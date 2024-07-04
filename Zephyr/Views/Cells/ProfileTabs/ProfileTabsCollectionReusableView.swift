//
//  ProfileTabsCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 30/06/24.
//

import UIKit
protocol ProfileTabsCollectionReusableViewDelegate: AnyObject{
    func didTapPostsButton()
    func didTapVideoPostsButton()
    func didTapTaggedUserPostsButton()
}
class ProfileTabsCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var videoPostsButton: UIButton!
    @IBOutlet weak var taggedUserPostsButton: UIButton!
    weak var delegate: ProfileTabsCollectionReusableViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func postsButtonTapped(_ sender: UIButton) {
        delegate?.didTapPostsButton()
    }
    @IBAction func videoPostsButtonTapped(_ sender: UIButton) {
        delegate?.didTapVideoPostsButton()
    }
    
    @IBAction func taggedUserPostsButtonTapped(_ sender: UIButton) {
        delegate?.didTapTaggedUserPostsButton()
    }
}
