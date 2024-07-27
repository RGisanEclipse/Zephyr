//
//  CommentsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 11/07/24.
//

import UIKit

class CommentsViewController: UIViewController {
    
    var model: UserPost?
    private var userData: UserModel?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var commentsTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = " "
        tableView.register(UINib(nibName: Constants.Post.generalCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.generalCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.commentsHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.commentsHeaderCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        fetchUserData()
        userProfileImage.layer.cornerRadius = userProfileImage.frame.size.width / 2
        userProfileImage.layer.masksToBounds = true
        if let safeModel = model{
            commentsTextField.placeholder = "Add a comment to \(safeModel.owner.userName)'s post"
        }
        commentsTextField.delegate = self
    }
    private func fetchUserData(){
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (user, success) in
            guard let self = self, success, let user = user else {
                return
            }
            self.userData = user
            userProfileImage.sd_setImage(with: user.profilePicture, placeholderImage: UIImage(systemName: "person.circle.fill"))
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    @IBAction func postCommentButtonPressed(_ sender: UIButton) {
    }
}

// MARK: - UITableViewDataSource
extension CommentsViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else{
            return model?.comments.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let safeModel = model else{
            return UITableViewCell()
        }
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.commentsHeaderCellIdentifier, for: indexPath) as! CommentsHeaderTableViewCell
            cell.configure(with: safeModel)
            cell.delegate = self
            return cell
        } else{
            let commentsModel = safeModel.comments
            let currentComment = commentsModel[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.generalCellIdentifier, for: indexPath) as! PostGeneralTableViewCell
            cell.configure(with: currentComment)
            return cell
        }
    }
}

// MARK: - CommentsHeaderTableViewCellDelegate
extension CommentsViewController: CommentsHeaderTableViewCellDelegate{
    func didTapPostButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension CommentsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - UITextFieldDelegate
extension CommentsViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationController?.navigationBar.isHidden = true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationController?.navigationBar.isHidden = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
