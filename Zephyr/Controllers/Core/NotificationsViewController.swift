//
//  NotificationsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationsView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
//        noNotificationsView.isHidden = true
//        spinner.startAnimating()
    }
    
}
