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
    func configure(with model: UserPost) {
        self.model = model
        dateLabel.text = formattedDateString(from: model.createDate)
    }
    private func formattedDateString(from date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .year], from: date, to: now)
        
        if let weeks = components.weekOfYear, weeks >= 1 {
            let dateFormatter = DateFormatter()
            let currentYear = calendar.component(.year, from: now)
            let dateYear = calendar.component(.year, from: date)
            
            if currentYear == dateYear {
                dateFormatter.dateFormat = "MMM d"
            } else {
                dateFormatter.dateFormat = "MMM yyyy"
            }
            return dateFormatter.string(from: date)
        } else if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) min ago"
        } else {
            return "just now"
        }
    }
    
    @IBAction func commentsButtonPressed(_ sender: UIButton) {
        guard let postModel = model else{
            return
        }
        delegate?.didTapCommentsButton(with: postModel)
    }
}
