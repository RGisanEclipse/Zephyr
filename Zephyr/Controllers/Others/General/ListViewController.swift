//
//  ListViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ListViewController: UIViewController {
    
    var data = [UserRelationship]()
    
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
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.List.cellIdentifier, for: indexPath) as! ListTableViewCell
        cell.configure(with: data[indexPath.row])
        cell.delegate = self
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UserFollowTableViewCellDelegate
extension ListViewController: UserFollowTableViewCellDelegate{
    func didTapFollowButton(model: UserRelationship) {
        switch model.type{
        case .following:
            // Unfollow Logic
            break
        case.notFollowing:
            // Follow Logic
            break
        }
    }
}
