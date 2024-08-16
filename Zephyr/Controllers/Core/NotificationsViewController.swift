//
//  NotificationsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
import NVActivityIndicatorView
class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var loadingSpinner: NVActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationsView: UIStackView!
    @IBOutlet weak var refreshButton: UIButton!
    private var refreshControl = UIRefreshControl()
    private var models = [UserNotificationModel]()
    private var postModel: PostSummary?
    var userProfileSegueUserName: String?
    private var currentUserData: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noNotificationsView.isHidden = true
        fetchCurrentUserData()
        fetchNotifications()
        loadingSpinner.type = .circleStrokeSpin
        loadingSpinner.color = .BW
        loadingSpinner.startAnimating()
        refreshButton.layer.cornerRadius = CGFloat(8)
        refreshButton.backgroundColor = UIColor(named: "BW")
        view.bringSubviewToFront(loadingSpinner)
        tableView.register(UINib(nibName: Constants.Notifications.likeCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Notifications.likeCellIdentifier)
        tableView.register(UINib(nibName: Constants.Notifications.followCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Notifications.followCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    @objc private func refreshData(_ sender: Any) {
        fetchNotifications()
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
    private func fetchNotifications() {
        guard let user = currentUserData else {
            print("Current user data not available")
            return
        }
        DatabaseManager.shared.fetchNotificationsForUser(user: user) { [weak self] notifications in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.models = notifications
                self.tableView.reloadData()
                self.loadingSpinner.stopAnimating()
                self.loadingSpinner.isHidden = true
                if self.models.isEmpty {
                    self.noNotificationsView.isHidden = false
                } else {
                    self.noNotificationsView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        fetchNotifications()
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let user = currentUserData else {
            return nil
        }
        
        let notification = models[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            switch notification.type {
            case .follow(_):
                let viewedUserName = notification.user.userName
                DatabaseManager.shared.fetchNotificationIDforFollow(for: user.userName, with: viewedUserName) { notificationID in
                    guard let notificationID = notificationID else {
                        completionHandler(false)
                        return
                    }
                    DatabaseManager.shared.removeNotification(notificationID: notificationID) { success in
                        if success {
                            self.models.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            if self.models.isEmpty {
                                self.noNotificationsView.isHidden = false
                            }
                        } else {
                            print("Failed to delete notification")
                        }
                        completionHandler(success)
                    }
                }
                
            case .like(let post):
                DatabaseManager.shared.fetchNotificationIDforLike(for: user.userName, by: notification.user.userName, postIdentifier: post.identifier) { notificationID in
                    guard let notificationID = notificationID else {
                        completionHandler(false)
                        return
                    }
                    DatabaseManager.shared.removeNotification(notificationID: notificationID) { success in
                        if success {
                            self.models.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            if self.models.isEmpty {
                                self.noNotificationsView.isHidden = false
                            }
                        } else {
                            print("Failed to delete notification")
                        }
                        completionHandler(success)
                    }
                }
            }
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
