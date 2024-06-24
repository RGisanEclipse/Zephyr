//
//  FormTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 22/06/24.
//

import UIKit

protocol FormTableViewDelegate: AnyObject {
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel)
}

class FormTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    public weak var delegate: FormTableViewDelegate?
    var model: EditProfileFormModel?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        let textFieldWidthConstraint = textField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 3/5)
        textFieldWidthConstraint.isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        model?.value = textField.text
        guard let model = model
        else{
            return true
        }
        delegate?.formTableViewCell(self, didUpdateField: model)
        textField.resignFirstResponder()
        return true
    }
}

