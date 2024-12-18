//
//  SettingsSimpleTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 18/12/24.
//

import UIKit

class SettingsSimpleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(with name: String){
        titleLabel.text = name
        if name == "Logout"{
            titleLabel.textColor = .red
        } else if name == Constants.CurrentAppVersion{
            titleLabel.textColor = .systemGray
        }
    }
}
