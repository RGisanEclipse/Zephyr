//
//  PostViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var model: UserPost?
    private var likesData: [PostLike]?
    private var renderModels = [PostRenderViewModel]()
    private var userData: UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Post"
        configureModels()
        guard model != nil else {
            fatalError("Model is nil")
        }
        fetchUserData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.Post.headerCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.headerCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.postCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.postCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.actionsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.actionsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.likesCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.likesCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.captionCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.captionCellIdentifier)
        tableView.register(UINib(nibName: Constants.Home.commentsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Home.commentsCellIdentifier)
    }
    private func fetchUserData(){
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (user, success) in
            guard let self = self, success, let user = user else {
                return
            }
            self.userData = user
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Post"
        for cell in tableView.visibleCells{
            if let postCell = cell as? PostTableViewCell {
                postCell.playVideo()
                postCell.unMuteVideo()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        for cell in tableView.visibleCells{
            if let postCell = cell as? PostTableViewCell {
                postCell.pauseVideo()
                postCell.muteVideo()
            }
        }
    }
    private func configureModels(){
        guard let userPostModel = self.model else{
            return
        }
        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.owner)))
        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))
        renderModels.append(PostRenderViewModel(renderType: .actions(provider: userPostModel)))
        renderModels.append(PostRenderViewModel(renderType: .likes(provider: userPostModel.likeCount)))
        renderModels.append(PostRenderViewModel(renderType: .caption(provider: userPostModel.caption ?? "")))
        renderModels.append(PostRenderViewModel(renderType: .comments(provider: userPostModel)))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Post.likesSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Likes"
            guard let likesSafeData = likesData else{
                return
            }
            guard let safeUserData = userData else{
                return
            }
            destinationVC.data = safeUserData.convertPostLikesToUserRelationships(postLikes: likesSafeData)
        }
        if segue.identifier == Constants.Post.commentsSegue{
            let destinationVC = segue.destination as! CommentsViewController
            destinationVC.model = model
        }
    }
}

// MARK: - UITableViewDataSource
extension PostViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return renderModels.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch renderModels[section].renderType{
        case .actions(_): return 1
        case .comments(_): return 1
        case .header(_): return 1
        case .primaryContent(_): return 1
        case .likes(_): return 1
        case .caption(_): return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = renderModels[indexPath.section]
        guard let safeUserData = userData else{
            return UITableViewCell()
        }
        switch model.renderType{
        case .actions(let actions):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.actionsCellIdentifier, for: indexPath) as! PostActionsTableViewCell
            cell.configure(with: actions, userName: safeUserData.userName, indexPath: indexPath)
            cell.delegate = self
            return cell
        case .comments(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Home.commentsCellIdentifier, for: indexPath) as! HomeCommentsTableViewCell
            cell.configure(with: post)
            cell.delegate = self
            return cell
        case .header(let user):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.headerCellIdentifier, for: indexPath) as! PostHeaderTableViewCell
            cell.delegate = self
            cell.configure(with: user)
            return cell
        case .primaryContent(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.postCellIdentifier, for: indexPath) as! PostTableViewCell
            cell.configure(with: post)
            return cell
        case .likes(provider: let likes):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.likesCellIdentifier, for: indexPath) as! PostLikesTableViewCell
            cell.configure(with: likes)
            cell.delegate = self
            return cell
        case .caption(provider: let caption):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.captionCellIdentifier, for: indexPath) as! PostCaptionTableViewCell
            cell.configure(with: caption)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = renderModels[indexPath.section]
        switch model.renderType{
        case .header(_): return 60
        case .actions(_): return 50
        case .primaryContent(_): return view.frame.width
        case .comments(_): return 50
        case .likes(_): return 20
        case .caption(let caption):
            if caption.count == 0{
                return 0
            }
            return calculateHeightForCaption(caption)
        }
    }
    private func calculateHeightForCaption(_ caption: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12)
        let width = tableView.bounds.width - 32
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = caption.boundingRect(with: constraintRect,
                                               options: .usesLineFragmentOrigin,
                                               attributes: [NSAttributedString.Key.font: font],
                                               context: nil)
        let height = ceil(boundingBox.height) + 10
        return height
    }
}

// MARK: - UITableViewDelegate
extension PostViewController: UITableViewDelegate{
    
}

// MARK: - PostHeaderTableViewCellDelegate

extension PostViewController: PostHeaderTableViewCellDelegate{
    func didTapMoreButton() {
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in
            self?.reportPost()
        }))
        present(actionSheet, animated: true)
    }
    func reportPost(){
        
    }
}

// MARK: - PostActionsTableViewCellDelegate
extension PostViewController: PostActionsTableViewCellDelegate{
    func didTapLikeButton(with model: UserPost, from cell: PostActionsTableViewCell, at indexPath: IndexPath) {
        guard let safeUserData = userData else {
            return
        }
        let isLikedByCurrentUser = model.likeCount.contains { like in
            like.userName == safeUserData.userName
        }
        if isLikedByCurrentUser {
            DatabaseManager.shared.removeLike(to: model.identifier, from: safeUserData) { success in
                if success {
                    var newModel = model
                    var updatedLikeCount = model.likeCount
                    updatedLikeCount.removeAll { like in
                        like.userName == safeUserData.userName
                    }
                    newModel.likeCount = updatedLikeCount
                    self.updateRenderModels(with: newModel)
                    DispatchQueue.main.async {
                        self.tableView.reloadSections([2,3], with: .none)
                    }
                }
            }
        } else {
            DatabaseManager.shared.addLike(to: model.identifier, from: safeUserData) { success in
                if success {
                    var newModel = model
                    var updatedLikeCount = model.likeCount
                    updatedLikeCount.append(PostLike(userName: safeUserData.userName, postIdentifier: model.identifier))
                    newModel.likeCount = updatedLikeCount
                    self.updateRenderModels(with: newModel)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadSections([2,3], with: .none)
                    }
                }
            }
        }
    }
    private func updateRenderModels(with newModel: UserPost) {
        for (index, var renderModel) in renderModels.enumerated() {
            switch renderModel.renderType {
            case .primaryContent:
                renderModel = PostRenderViewModel(renderType: .primaryContent(provider: newModel))
            case .actions:
                renderModel = PostRenderViewModel(renderType: .actions(provider: newModel))
            case .likes:
                renderModel = PostRenderViewModel(renderType: .likes(provider: newModel.likeCount))
            case .caption:
                renderModel = PostRenderViewModel(renderType: .caption(provider: newModel.caption ?? ""))
            case .comments:
                renderModel = PostRenderViewModel(renderType: .comments(provider: newModel))
            case .header:
                // Handle header if necessary
                break
            }
            renderModels[index] = renderModel
        }
    }
    
    func didTapSaveButton(with model: UserPost) {
        // Logic to save the post
    }
    
    func didTapCommentButton(with model: UserPost) {
        self.performSegue(withIdentifier: Constants.Post.commentsSegue, sender: self)
    }
}

// MARK: - PostLikesTableViewCellDelegate
extension PostViewController: PostLikesTableViewCellDelegate{
    func didTapLikesButton(with likesData: [PostLike]) {
        self.likesData = likesData
        self.performSegue(withIdentifier: Constants.Post.likesSegue, sender: self)
    }
}

// MARK: - HomeCommentsTableViewCellDelegate
extension PostViewController: HomeCommentsTableViewCellDelegate{
    func didTapCommentsButton(with model: UserPost) {
        self.performSegue(withIdentifier: Constants.Post.commentsSegue, sender: self)
    }
}
