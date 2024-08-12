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
    private var refreshControl = UIRefreshControl()
    private var models = [UserNotificationModel]()
    private var postModel: PostSummary?
    var userProfileSegueUserName: String?
    private var currentUserData: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUserData()
        fetchNotifications()
        if models.isEmpty{
            tableView.isHidden = true
        } else{
            noNotificationsView.isHidden = true
            tableView.isHidden = false
        }
        //        spinner.startAnimating()
        spinner.isHidden = true
        tableView.register(UINib(nibName: Constants.Notifications.likeCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Notifications.likeCellIdentifier)
        tableView.register(UINib(nibName: Constants.Notifications.followCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Notifications.followCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    @objc private func refreshData(_ sender: Any) {
        // Fetch Notifications
        self.refreshControl.endRefreshing()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Notifications"
    }
    private func fetchCurrentUserData(){
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (user, success) in
            guard let self = self, success, let user = user else {
                return
            }
            self.currentUserData = user
        }
    }
    private func fetchNotifications(){
            let post = PostSummary(identifier: "xyz", thumbnailImage: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, postType: .photo )
            let model = UserNotificationModel(type: .like(post: post), text: "TheJoker started following you.", user: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), posts: [], followers: [], following: []), identifier: "x")
            models.append(model)
    }
}
// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        switch model.type{
        case .like(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Notifications.likeCellIdentifier, for: indexPath) as! NotificationLikeTableViewCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        case .follow:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Notifications.followCellIdentifier, for: indexPath) as! NotificationFollowTableViewCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Notifications.postSegue{
            let destinationVC = segue.destination as! PostViewController
            destinationVC.postIdentifier = postModel?.identifier
        } else if segue.identifier == Constants.Notifications.userProfileSegue{
            let destinationVC = segue.destination as! UserProfileViewController
            destinationVC.segueUserName = userProfileSegueUserName
        }
    }
}

// MARK: - NotificationLikeTableViewCellDelegate
extension NotificationsViewController: NotificationLikeTableViewCellDelegate{
    func didTapProfilePictureButton(with userName: String) {
        self.userProfileSegueUserName = userName
        self.performSegue(withIdentifier: Constants.Notifications.userProfileSegue, sender: self)
    }
    func didTapPostButton(with model: UserNotificationModel) {
        switch model.type{
        case .like(let post):
            self.postModel = post
        case .follow(_):
            print("Dev issue! Should never be called")
            break
        }
        self.performSegue(withIdentifier: Constants.Notifications.postSegue, sender: self)
    }
}

extension NotificationsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - NotificationFollowTableViewCellDelegate
extension NotificationsViewController: NotificationFollowTableViewCellDelegate{
    func didTapFollowButton(with model: UserNotificationModel, cell: NotificationFollowTableViewCell) {
        guard let currentUser = self.currentUserData else { return }
        let currentUserName = currentUser.userName
        let viewedUserName = model.user.userName
        
        switch model.type {
        case .follow(let state):
            if state == .following {
                DatabaseManager.shared.unfollowUser(followerUserName: currentUserName, followedUserName: viewedUserName) { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.updateFollowState(for: model, in: cell, to: .notFollowing)
                        DatabaseManager.shared.fetchNotificationIDforFollow(for: viewedUserName, with: currentUserName) { notificationID in
                            guard let notificationID = notificationID else { return }
                            DatabaseManager.shared.removeNotification(notificationID: notificationID) { success in
                                if success{
                                    print("Notification removed from database")
                                } else{
                                    print("Failed to remove notification to database")
                                }
                            }
                        }
                    } else {
                        print("Failed to unfollow user")
                    }
                }
            } else {
                DatabaseManager.shared.followUser(followerUserName: currentUserName, followedUserName: viewedUserName, followerProfilePicture: currentUser.profilePicture?.absoluteString ?? "", followedUserProfilePicture: model.user.profilePicture?.absoluteString ?? "") { success in
                    if success {
                        self.updateFollowState(for: model, in: cell, to: .following)
                        DatabaseManager.shared.addNotification(to: viewedUserName, from: currentUser, type: "follow", post: nil, notificationText: "\(currentUserName) started following you.") { success in
                            if success{
                                print("Notification added to database")
                            } else{
                                print("Failed to add notification to database")
                            }
                        }
                    } else {
                        print("Failed to follow user")
                    }
                }
            }
        case .like:
            break
        }
    }
    
    private func updateFollowState(for model: UserNotificationModel, in cell: NotificationFollowTableViewCell, to newState: FollowState) {
        var newModel = model
        newModel.type = .follow(state: newState)
        cell.configure(with: newModel)
        
        if let index = models.firstIndex(where: { $0.user.userName == model.user.userName }) {
            models[index] = newModel
        }
    }
    func didTapProfilePictureButtonF(with userName: String) {
        self.userProfileSegueUserName = userName
        self.performSegue(withIdentifier: Constants.Notifications.userProfileSegue, sender: self)
    }
}
