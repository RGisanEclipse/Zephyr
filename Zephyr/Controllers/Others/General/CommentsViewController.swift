//
//  CommentsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 11/07/24.
//

import UIKit

protocol CommentsViewControllerDelegate: AnyObject {
    func didUpdateComments(_ comments: [PostComment], _ post: UserPost)
}

class CommentsViewController: UIViewController {
    
    var model: UserPost?
    private var userData: UserModel?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var commentsTextField: UITextField!
    weak var delegate: CommentsViewControllerDelegate?
    
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
        guard let commentText = commentsTextField.text, !commentText.isEmpty else{
            // Empty comment scenario
            return
        }
        guard let postID = model?.identifier, let currentUser = userData else {
            // Error fetching post or userData
            return
        }
        let newComment = PostComment(postIdentifier: postID,
                                     user: currentUser,
                                     text: commentText,
                                     createdDate: Date(),
                                     likes: [],
                                     commentIdentifier: UUID().uuidString)
        DatabaseManager.shared.addComment(to: postID, comment: newComment){ success in
            if success{
                DispatchQueue.main.async {
                    self.commentsTextField.text = ""
                    var newModel = self.model
                    newModel?.comments.insert(newComment, at: 0)
                    self.model = newModel
                    let indexSet = IndexSet(integer: 1)
                    self.tableView.reloadSections(indexSet, with: .fade)
                }
            } else{
                let alert = UIAlertController(title: "Error posting comment", message: "There was an internal server error while posting the comment", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
                    alert.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section == 1, let currentUser = userData else { return nil }
        let comment = model?.comments[indexPath.row]
        if comment?.user.userName == currentUser.userName {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
                self?.deleteComment(at: indexPath)
                completionHandler(true)
            }
            deleteAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            let reportAction = UIContextualAction(style: .normal, title: "Report") { [weak self] _, _, completionHandler in
                self?.reportComment(at: indexPath)
                completionHandler(true)
            }
            reportAction.backgroundColor = .gray
            return UISwipeActionsConfiguration(actions: [reportAction])
        }
    }
    private func deleteComment(at indexPath: IndexPath) {
        guard let postID = model?.identifier else { return }
        guard let commentToDelete = model?.comments[indexPath.row] else{
            return
        }
        DatabaseManager.shared.deleteComment(from: postID, comment: commentToDelete) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.model?.comments.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    guard let safeModel = self?.model else { return }
                    let safeComments = safeModel.comments
                    self?.delegate?.didUpdateComments(safeComments,safeModel)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to delete the comment.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    private func reportComment(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Report Comment", message: "Are you sure you want to report this comment?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            guard let commentToReport = self.model?.comments[indexPath.row] else {
                return
            }
            DatabaseManager.shared.reportComment(comment: commentToReport) { success in
                if success {
                    DispatchQueue.main.async {
                        self.model?.comments.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        guard let safeModel = self.model else { return }
                        let safeComments = safeModel.comments
                        self.delegate?.didUpdateComments(safeComments,safeModel)
                        let confirmationAlert = UIAlertController(title: "Comment Reported", message: "This comment has been reported and hidden from your view.", preferredStyle: .alert)
                        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(confirmationAlert, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        let errorAlert = UIAlertController(title: "Error Reporting Comment", message: "There was an error while reporting the comment.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
