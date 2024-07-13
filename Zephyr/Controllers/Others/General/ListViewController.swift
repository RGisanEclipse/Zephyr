//
//  ListViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ListViewController: UIViewController {
    
    var data = [UserRelationship]()
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var viewTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationItem.title = viewTitle ?? "List View"
        if data.isEmpty{
            tableView.isHidden = true
            emptyView.isHidden = false
            emptyLabel.text = "No \(viewTitle ?? "")"
        }
        tableView.register(UINib(nibName: Constants.List.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.List.cellIdentifier)
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        self.refreshControl.endRefreshing()
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
