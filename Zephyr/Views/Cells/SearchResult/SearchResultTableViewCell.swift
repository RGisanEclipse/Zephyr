//
//  SearchResultTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/08/24.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var fullName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.borderWidth = 0.2
        profilePicture.layer.borderColor = CGColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        profilePicture.clipsToBounds = true
    }
    func configure(with model: UserModel){
        profilePicture.sd_setImage(with: model.profilePicture, placeholderImage: UIImage(named: "userPlaceholder"))
        userName.text = model.userName
        fullName.text = "\(model.name?.first ?? "") \(model.name?.last ?? "")"
    }
}
