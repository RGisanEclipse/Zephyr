//
//  HomeViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import FirebaseAuth
import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    private var feedRenderModels = [HomeRenderViewModel]()
    private var likesData: [PostLike]?
    private var postSegueModel: UserPost?
    private var userData: UserModel?
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        fetchUserData()
        createMockModels()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.Post.headerCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.headerCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.postCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.postCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.actionsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.actionsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.captionCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.captionCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.likesCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.likesCellIdentifier)
        tableView.register(UINib(nibName: Constants.Home.commentsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Home.commentsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Home.logoCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Home.logoCellIdentifier)
        tableView.reloadData()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    private func fetchUserData(){
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (user, success) in
            guard let self = self, success, let user = user else {
                return
            }
            self.userData = user
        }
    }
    @objc private func refreshData(_ sender: Any) {
        // Fetch Posts
        self.refreshControl.endRefreshing()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
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
    private func createMockModels(){
        DispatchQueue.global().async {
            var comments = [PostComment]()
            comments.append(PostComment(postIdentifier: "x", user: UserModel(userName: "TheJoker", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/images/images/035/033/866/large/alexander-hodlmoser-square-color.jpg?1613934885")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), posts:[], followers: [], following: []), text: "Wanna know how I got that smile?", createdDate: Date(), likes: [],commentIdentifier: "abc"))
            comments.append(PostComment(postIdentifier: "y", user: UserModel(userName: "TheRiddler", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/covers/images/006/212/068/large/william-gray-gotham-riddler-square.jpg?1496839509")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), posts:[],followers: [], following: []), text: "Let's meet at Iceberg Lounge :)", createdDate: Date(), likes: [], commentIdentifier: "bca"))
            let post = UserPost(identifier: "abc", postType: .photo, thumbnailImage: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, postURL: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, caption: "The Batman (2022)", likeCount: [PostLike(userName: "TheJoker", postIdentifier: "x"), PostLike(userName: "TheRiddler", postIdentifier: "x")], comments: comments, createDate: Date(), taggedUsers: [], owner: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), posts:[],followers: [], following: []))
            let post2 = UserPost(identifier: "xyz", postType: .photo, thumbnailImage: URL(string: "https://www.cnet.com/a/img/resize/ea66ddc9276eef2884da221adc70ed1cf1545951/hub/2021/10/16/11804578-0dbc-42af-bcd1-3bc7b1394962/the-batman-2022-teaser-poster-batman-01-promo.jpg?auto=webp&fit=crop&height=675&width=1200")!, postURL: URL(string: "https://www.cnet.com/a/img/resize/ea66ddc9276eef2884da221adc70ed1cf1545951/hub/2021/10/16/11804578-0dbc-42af-bcd1-3bc7b1394962/the-batman-2022-teaser-poster-batman-01-promo.jpg?auto=webp&fit=crop&height=675&width=1200")!, caption: "The Batman (2022) post 2", likeCount: [PostLike(userName: "TheJoker", postIdentifier: "x"), PostLike(userName: "TheRiddler", postIdentifier: "xy")], comments: comments, createDate: Date(), taggedUsers: [], owner: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), posts:[],followers: [], following: []))
            let viewModel = HomeRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: post)),
                                                post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                                                actions: PostRenderViewModel(renderType: .actions(provider: post)),
                                                likes: PostRenderViewModel(renderType: .likes(provider: post.likeCount)),
                                                caption: PostRenderViewModel(renderType: .caption(provider: post.caption ?? "")),
                                                comments: PostRenderViewModel(renderType: .comments(provider: post)))
            let secondViewModel = HomeRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: post)),
                                                      post: PostRenderViewModel(renderType: .primaryContent(provider: post2)),
                                                      actions: PostRenderViewModel(renderType: .actions(provider: post2)),
                                                      likes: PostRenderViewModel(renderType: .likes(provider: post2.likeCount)),
                                                      caption: PostRenderViewModel(renderType: .caption(provider: post2.caption ?? "")),
                                                      comments: PostRenderViewModel(renderType: .comments(provider: post2)))
            self.feedRenderModels.append(viewModel)
            self.feedRenderModels.append(secondViewModel)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Home.likesSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Likes"
            guard let likesSafeData = likesData else{
                return
            }
            destinationVC.data = userData!.convertPostLikesToUserRelationships(postLikes: likesSafeData)
        } else if segue.identifier == Constants.Home.commentsSegue{
            let destinationVC = segue.destination as! CommentsViewController
            destinationVC.model = postSegueModel
            destinationVC.delegate = self
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate{
    
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRenderModels.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Home.logoCellIdentifier, for: indexPath) as! HomeLogoTableViewCell
            cell.delegate = self
            return cell
        } else {
            let model = feedRenderModels[indexPath.section - 1]
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.headerCellIdentifier, for: indexPath) as! PostHeaderTableViewCell
                if case .header(let post) = model.header.renderType {
                    cell.configure(with: post)
                }
                cell.delegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.postCellIdentifier, for: indexPath) as! PostTableViewCell
                if case .primaryContent(let post) = model.post.renderType {
                    cell.configure(with: post)
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.actionsCellIdentifier, for: indexPath) as! PostActionsTableViewCell
                if case .actions(let provider) = model.actions.renderType {
                    cell.configure(with: provider, userName: userData?.userName ?? "", indexPath: indexPath)
                }
                cell.delegate = self
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.likesCellIdentifier, for: indexPath) as! PostLikesTableViewCell
                if case .likes(let likes) = model.likes.renderType {
                    cell.configure(with: likes)
                }
                cell.delegate = self
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.captionCellIdentifier, for: indexPath) as! PostCaptionTableViewCell
                if case .caption(let caption) = model.caption.renderType {
                    cell.configure(with: caption)
                }
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Home.commentsCellIdentifier, for: indexPath) as! HomeCommentsTableViewCell
                if case .comments(let post) = model.comments.renderType {
                    cell.configure(with: post)
                }
                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40
        } else {
            switch indexPath.row {
            case 0:
                return 60
            case 1:
                return view.frame.width
            case 2:
                return 50
            case 3:
                return 20
            case 4:
                let model = feedRenderModels[indexPath.section - 1].caption
                if case .caption(let captionText) = model.renderType {
                    return calculateHeightForCaption(captionText)
                }
                return 0
            case 5:
                return 50
            default:
                return 0
            }
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
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let subSection = section % 7
        return subSection == 6 ? 10 : 0
    }
}
// MARK: - PostHeaderTableViewCellDelegate
extension HomeViewController: PostHeaderTableViewCellDelegate{
    func didTapMoreButton(for post: UserPost) {
        guard let safeUserData = userData else {
            return
        }
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if post.owner.userName == safeUserData.userName {
            actionSheet.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { [weak self] _ in
                self?.confirmPostDeletion(post: post)
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in
                self?.reportPost(post: post)
            }))
        }
        
        present(actionSheet, animated: true)
    }
    
    private func confirmPostDeletion(post: UserPost) {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deletePost(post: post)
        }))
        present(alert, animated: true)
    }
    private func deletePost(post: UserPost) {
        let mediaURL = post.postURL
        let thumbnailURL = post.thumbnailImage
        guard let storagePath = extractStoragePath(from: mediaURL) else { return }
        guard let thumbnailStoragePath = extractStoragePath(from: thumbnailURL) else { return }
        let isVideo = post.postType == .video
        DatabaseManager.shared.deletePost(with: post.identifier) { [weak self] success in
            guard success else {
                print("Failed to delete post from Firestore")
                return
            }
            DatabaseManager.shared.deleteLikes(for: post.identifier) { success in
                if success {
                    print("Successfully deleted likes for post")
                } else {
                    print("Failed to delete likes for post")
                }
            }
            DatabaseManager.shared.deleteComments(for: post.identifier) { success in
                if success {
                    print("Successfully deleted comments for post")
                } else {
                    print("Failed to delete comments for post")
                }
            }
            StorageManager.shared.deleteMedia(reference: storagePath, isVideo: isVideo) { success in
                if success {
                    print("Successfully deleted media from Storage")
                } else {
                    print("Failed to delete media from Storage")
                }
            }
            if isVideo {
                StorageManager.shared.deleteMedia(reference: thumbnailStoragePath, isVideo: false) { success in
                    if success {
                        print("Successfully deleted thumbnail from Storage")
                    } else {
                        print("Failed to delete thumbnail from Storage")
                    }
                }
            }
            DispatchQueue.main.async {
                if let index = self?.findIndexOfPost(post) {
                    self?.feedRenderModels.remove(at: index)
                    self?.tableView.reloadData()
                }
            }
        }
    }
    func extractStoragePath(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        guard let pathComponent = urlComponents.path.split(separator: "/").last else {
            return nil
        }
        let decodedPath = pathComponent.removingPercentEncoding
        return decodedPath
    }
    func reportPost(post: UserPost) {
        let alert = UIAlertController(title: "Confirm Report", message: "Are you sure you want to report this post? It will be hidden from you.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { [weak self] _ in
            DatabaseManager.shared.reportPost(post) { success in
                if success{
                    let confirmationAlert = UIAlertController(title: "Post Reported", message: "This post has been reported and will be held for a review.", preferredStyle: .alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(confirmationAlert, animated: true, completion: nil)
                    DispatchQueue.main.async {
                        if let index = self?.findIndexOfPost(post) {
                            self?.feedRenderModels.remove(at: index)
                            self?.tableView.reloadData()
                        }
                    }
                } else{
                    print("Error reporting the post")
                }
            }
        }))
        self.present(alert, animated: true)
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let subSection = indexPath.section % 7
        if subSection == 2{
            if let postCell = cell as? PostTableViewCell {
                postCell.pauseVideo()
                postCell.muteVideo()
            }
        }
    }
}

// MARK: - PostActionsTableViewCellDelegate
extension HomeViewController: PostActionsTableViewCellDelegate {
    
    func didTapCommentButton(with model: UserPost) {
        self.postSegueModel = model
        self.performSegue(withIdentifier: Constants.Home.commentsSegue, sender: self)
    }
    
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
                    self.feedRenderModels[indexPath.section - 1].post = PostRenderViewModel(renderType: .primaryContent(provider: newModel))
                    self.feedRenderModels[indexPath.section - 1].likes = PostRenderViewModel(renderType: .likes(provider: updatedLikeCount))
                    
                    DispatchQueue.main.async {
                        cell.configure(with: newModel, userName: safeUserData.userName, indexPath: indexPath)
                        let likesIndexPath = IndexPath(row: 3, section: indexPath.section)
                        self.tableView.reloadRows(at: [likesIndexPath], with: .none)
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
                    self.feedRenderModels[indexPath.section - 1].post = PostRenderViewModel(renderType: .primaryContent(provider: newModel))
                    self.feedRenderModels[indexPath.section - 1].likes = PostRenderViewModel(renderType: .likes(provider: updatedLikeCount))
                    
                    DispatchQueue.main.async {
                        cell.configure(with: newModel, userName: safeUserData.userName, indexPath: indexPath)
                        let likesIndexPath = IndexPath(row: 3, section: indexPath.section)
                        self.tableView.reloadRows(at: [likesIndexPath], with: .none)
                    }
                }
            }
        }
    }
    
    func didTapSaveButton(with model: UserPost) {
        // Logic to save the post
    }
}


// MARK: - PostLikesTableViewCellDelegate
extension HomeViewController: PostLikesTableViewCellDelegate{
    func didTapLikesButton(with likesData: [PostLike]) {
        self.likesData = likesData
        self.performSegue(withIdentifier: Constants.Home.likesSegue, sender: self)
    }
}

// MARK: - HomeLogoTableViewCellDelegate
extension HomeViewController: HomeLogoTableViewCellDelegate{
    func didTapMessagesButton() {
        let alert = UIAlertController(title: "Messages", message: "Feature coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
            alert.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - HomeCommentsTableViewCellDelegate
extension HomeViewController: HomeCommentsTableViewCellDelegate{
    func didTapCommentsButton(with model: UserPost) {
        self.postSegueModel = model
        self.performSegue(withIdentifier: Constants.Home.commentsSegue, sender: self)
    }
}

// MARK: - CommentsViewControllerDelegate
extension HomeViewController: CommentsViewControllerDelegate{
    func findIndexOfPost(_ post: UserPost) -> Int? {
        return feedRenderModels.firstIndex(where: { viewModel in
            if case .primaryContent(let existingPost) = viewModel.post.renderType {
                return existingPost.identifier == post.identifier
            }
            return false
        })
    }
    func didUpdateComments(_ comments: [PostComment], _ post: UserPost) {
        if let index = findIndexOfPost(post) {
            var updatedPost = feedRenderModels[index].post
            if case .primaryContent(var postContent) = updatedPost.renderType {
                postContent.comments = comments
                updatedPost = PostRenderViewModel(renderType: .primaryContent(provider: postContent))
                feedRenderModels[index].post = updatedPost
                feedRenderModels[index].comments = PostRenderViewModel(renderType: .comments(provider: postContent))
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: 5, section: index + 1)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        } else {
            print("Post not found in feedRenderModels")
        }
    }
    
}
