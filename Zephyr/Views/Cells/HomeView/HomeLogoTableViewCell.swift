//
//  HomeLogoTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 08/07/24.
//

import UIKit
protocol HomeLogoTableViewCellDelegate: AnyObject{
    func didTapMessagesButton()
}
class HomeLogoTableViewCell: UITableViewCell {

    @IBOutlet weak var messagesButton: UIButton!
    weak var delegate: HomeLogoTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func messagesButtonPressed(_ sender: UIButton) {
        delegate?.didTapMessagesButton()
    }
}
