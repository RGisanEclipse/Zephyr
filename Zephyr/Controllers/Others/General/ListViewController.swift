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
    private var currentUserData: UserModel?
    var userProfileSegueUserName: String?
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var viewTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUserData()
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
        self.refreshControl.endRefreshing()
    }
    private func fetchCurrentUserData(){
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (user, success) in
            guard let self = self, success, let user = user else {
                return
            }
            self.currentUserData = user
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.List.userProfileVC{
            let destinationVC = segue.destination as! UserProfileViewController
            destinationVC.segueUserName = userProfileSegueUserName
        }
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
    func didTapUserNameButton(with userName: String) {
        self.userProfileSegueUserName = userName
        self.performSegue(withIdentifier: Constants.List.userProfileVC, sender: self)
    }
    
    func didTapProfilePictureButton(with userName: String) {
        self.userProfileSegueUserName = userName
        self.performSegue(withIdentifier: Constants.List.userProfileVC, sender: self)
    }
    
    func didTapFollowButton(model: UserRelationship, cell: ListTableViewCell) {
        guard let currentUser = self.currentUserData else { return }
        let currentUserName = currentUser.userName
        let viewedUserName = model.username
        switch model.type{
        case .following:
            DatabaseManager.shared.unfollowUser(followerUserName: currentUserName, followedUserName: viewedUserName) { success in
                if success {
                    var newModel = model
                    newModel.type = .notFollowing
                    cell.configure(with: newModel)
                } else {
                    print("Failed to unfollow user")
                }
            }
            break
        case.notFollowing:
            DatabaseManager.shared.followUser(followerUserName: currentUserName, followedUserName: viewedUserName, followerProfilePicture: currentUser.profilePicture?.absoluteString ?? "", followedUserProfilePicture: model.profilePicture ?? "") { success in
                if success {
                    var newModel = model
                    newModel.type = .following
                    cell.configure(with: newModel)
                } else {
                    print("Failed to follow user")
                }
            }
            break
        }
    }
}
