//
//  BioTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 28/12/24.
//

import UIKit
protocol BioTableViewDelegate: AnyObject {
    func bioTableViewCell(_ cell: BioTableViewCell, didUpdateField updatedModel: EditProfileFormModel)
}

class BioTableViewCell: UITableViewCell, UITextViewDelegate {
    
    public weak var delegate: BioTableViewDelegate?
    var model: EditProfileFormModel?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        let textFieldWidthConstraint = textField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 3/5)
        textFieldWidthConstraint.isActive = true
        textField.textContainerInset = UIEdgeInsets.zero
//        textField.textContainer.lineFragmentPadding = 0
        textField.textColor = .placeholderText
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        model?.value = textView.text
        guard let model = model else { return }
        delegate?.bioTableViewCell(self, didUpdateField: model)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return updatedText.count <= 120
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .BW
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.textColor = .placeholderText
    }
}