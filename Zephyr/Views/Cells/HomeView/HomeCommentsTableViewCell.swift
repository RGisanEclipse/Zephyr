//
//  HomeCommentsTableViewCell.swift
//  Zephyr
//
//  Created by Eclipse on 10/07/24.
//

import UIKit
protocol HomeCommentsTableViewCellDelegate: AnyObject{
    func didTapCommentsButton(with model: UserPost)
}

class HomeCommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewCommentsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: HomeCommentsTableViewCellDelegate?
    var model: UserPost?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(with model: UserPost){
        self.model = model
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
        let dateYear = calendar.component(.year, from: model.createDate)
            if currentYear == dateYear {
                dateFormatter.dateFormat = "MMM d"
            } else {
                dateFormatter.dateFormat = "MMM yyyy"
            }
        dateLabel.text = dateFormatter.string(from: model.createDate)
    }
    
    @IBAction func commentsButtonPressed(_ sender: UIButton) {
        guard let postModel = model else{
            return
        }
        delegate?.didTapCommentsButton(with: postModel)
    }
}
