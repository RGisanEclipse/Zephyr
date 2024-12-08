//
//  ViewUserProfileTabsCollectionReusableView.swift
//  Zephyr
//
//  Created by Eclipse on 08/12/24.
//

import UIKit
protocol ViewUserProfileTabsCollectionReusableViewDelegate:AnyObject{
    func didTapPostsButton()
    func didTapVideoPostsButton()
}
class ViewUserProfileTabsCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var videoPostsButton: UIButton!
    weak var delegate: ViewUserProfileTabsCollectionReusableViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
       super.layoutSubviews()
       setupBottomBorder()
    }
    
    @IBAction func postsButtonTapped(_ sender: UIButton) {
        videoPostsButton.tintColor = UIColor(named: "Tabs")
        postsButton.tintColor = UIColor(named: "BW")
        delegate?.didTapPostsButton()
    }

    @IBAction func videoPostsButtonTapped(_ sender: UIButton) {
        videoPostsButton.tintColor = UIColor(named: "BW")
        postsButton.tintColor = UIColor(named: "Tabs")
        delegate?.didTapVideoPostsButton()
    }

    private func setupBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: self.frame.height - 1.0, width: self.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomBorder)
    }
}
