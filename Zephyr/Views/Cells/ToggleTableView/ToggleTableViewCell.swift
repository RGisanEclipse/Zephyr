//
//  ToggleTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 18/12/24.
//

import UIKit

protocol ToggleTableViewCellDelegate: AnyObject {
    func toggleTableViewCellDidToggle(_ cell: ToggleTableViewCell, isOn: Bool)
}

class ToggleTableViewCell: UITableViewCell {

    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: ToggleTableViewCellDelegate?
    var cellTitle: String?
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    func configure(title: String, isOn: Bool) {
        self.cellTitle = title
        titleLabel.text = title
        toggleSwitch.isOn = isOn
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func toggledToggleSwitch(_ sender: UISwitch) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25){
            self.delegate?.toggleTableViewCellDidToggle(self, isOn: sender.isOn)
        }
    }
}
