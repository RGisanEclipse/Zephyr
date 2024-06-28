//
//  ListViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = viewTitle ?? "List View"
        tableView.register(UINib(nibName: Constants.List.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.List.cellIdentifier)
        tableView.dataSource = self
    }

}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listViewCell", for: indexPath) as! ListTableViewCell
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate{
    
}
