//
//  ProfileTabsCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 30/06/24.
//

import UIKit

protocol ProfileTabsCollectionReusableViewDelegate: AnyObject {
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

    override func layoutSubviews() {
       super.layoutSubviews()
       setupBottomBorder()
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

    private func setupBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1.0, width: self.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomBorder)
    }
}
