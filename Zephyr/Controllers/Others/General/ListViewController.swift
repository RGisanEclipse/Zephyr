//
//  ListViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ListViewController: UIViewController {
    var viewTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = viewTitle ?? "List View"
    }

}
