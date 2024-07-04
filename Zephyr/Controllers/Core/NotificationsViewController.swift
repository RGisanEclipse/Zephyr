//
//  NotificationsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

enum UserNotificationType{
    case like(post: UserPost)
    case follow(state: FollowState)
}

struct UserNotification{
    let type: UserNotificationType
    let text: String
    let user: UserModel
}

class NotificationsViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationsView: UIStackView!
    
    private var models = [UserNotification]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    private func fetchNotifications(){
        for x in 0...10{
            let post = UserPost(identifier: "", postType: .photo, thumbnailImage: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYVx6CB56pxO8gwlzLLOkV8fPN0jfF3T_98w&s")!, postURL: URL(string: "https://pbs.twimg.com/profile_images/1676116130275143680/BkUKyvp7_400x400.jpg")!, caption: nil, likeCount: [], comments: [], createDate: Date(), taggedUsers: [])
            let model = UserNotification(type: x%2==0 ? .like(post: post): .follow(state: .notFollowing), text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", user: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://pbs.twimg.com/profile_images/1676116130275143680/BkUKyvp7_400x400.jpg")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date()))
            models.append(model)
        }
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
}

// MARK: - NotificationLikeTableViewCellDelegate
extension NotificationsViewController: NotificationLikeTableViewCellDelegate{
    func didTapProfilePictureButton(with model: UserNotification) {
        print("Tapped ProfilePictureButton")
    }
    
    func didTapPostButton(with model: UserNotification) {
        print("Tapped PostButton")
    }
}

// MARK: - NotificationFollowTableViewCellDelegate
extension NotificationsViewController: NotificationFollowTableViewCellDelegate{
    func didTapFollowButton(with model: UserNotification) {
        print("Tapped FollowButton")
    }
    func didTapProfilePictureButtonF(with model: UserNotification) {
        print("Tapped ProfilePictureButtonF")
    }
}
