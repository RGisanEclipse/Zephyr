//
//  CommentsViewController.swift
//  Zephyr
//
//  Created by Eclipse on 11/07/24.
//

import UIKit

class CommentsViewController: UIViewController {
    var model: UserPost?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = " "
        tableView.register(UINib(nibName: Constants.Post.generalCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.generalCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.commentsHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.commentsHeaderCellIdentifier)
        tableView.dataSource = self
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
