//
//  GenderTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 28/04/25.
//

import UIKit
import StepSlider
protocol GenderTableViewDelegate: AnyObject {
    func genderTableViewCell(_ cell: GenderTableViewCell, didUpdateField updatedModel: EditProfileFormModel)
}
class GenderTableViewCell: UITableViewCell {
    
    weak var delegate: GenderTableViewDelegate?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var genderSlider: StepSlider!
    var model: EditProfileFormModel?
    var gender : String?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure (with gender: String){
        self.gender = gender
        setupGenderSlider()
    }
    func setupGenderSlider(){
        let genderSliderWidthConstraint = genderSlider.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 3/5)
        genderSliderWidthConstraint.isActive = true
        genderSlider.labels = [Gender.male.rawValue, Gender.female.rawValue, Gender.other.rawValue]
        genderSlider.labelColor = .placeholderText
        genderSlider.trackColor = .BW
        genderSlider.sliderCircleColor = .BW
        genderSlider.adjustLabel = true
        genderSlider.enableHapticFeedback = true
        switch gender{
        case Gender.male.rawValue:
            genderSlider.setIndex(0, animated: true)
        case Gender.female.rawValue:
            genderSlider.setIndex(1, animated: true)
        case Gender.other.rawValue:
            genderSlider.setIndex(2, animated: true)
        default:
            break
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func genderSliderValueChanged(_ sender: StepSlider) {
        let currentIndex = genderSlider.index
        switch currentIndex{
        case 0:
            gender = Gender.male.rawValue
        case 1:
            gender = Gender.female.rawValue
        case 2:
            gender = Gender.other.rawValue
        default:
            break
        }
        model?.value = gender
        guard let model = model else { return }
        delegate?.genderTableViewCell(self, didUpdateField: model)
    }
}
