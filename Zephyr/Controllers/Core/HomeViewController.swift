//
//  HomeViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import FirebaseAuth
import UIKit

class HomeViewController: UIViewController {
    private var feedRenderModels = [HomeRenderViewModel]()
    private var likesData: [PostLike]?
    private var postSegueModel: UserPost?
    private var userData = UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "It's not who you are underneath, it's what you do, that defines you.", name: (first: "Bruce", last: "Wayne"), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: ["TheJoker"], following: [])
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        createMockModels()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.Post.headerCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.headerCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.postCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.postCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.actionsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.actionsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.captionCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.captionCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.likesCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.likesCellIdentifier)
        tableView.register(UINib(nibName: Constants.Home.commentsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Home.commentsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Home.logoCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Home.logoCellIdentifier)
        for cell in tableView.visibleCells{
            if let postCell = cell as? PostTableViewCell{
                postCell.playVideo()
                postCell.muteVideo()
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scrollToTop()
    }
    func scrollToTop() {
        if feedRenderModels.isEmpty {
            return
        }
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    private func createMockModels(){
        var comments = [PostComment]()
        comments.append(PostComment(identifier: "x", user: UserModel(userName: "TheJoker", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/images/images/035/033/866/large/alexander-hodlmoser-square-color.jpg?1613934885")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: []), text: "Wanna know how I got that smile?", createdDate: Date(), likes: []))
        comments.append(PostComment(identifier: "y", user: UserModel(userName: "TheRiddler", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/covers/images/006/212/068/large/william-gray-gotham-riddler-square.jpg?1496839509")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: []), text: "Let's meet at Iceberg Lounge :)", createdDate: Date(), likes: []))
        let post = UserPost(identifier: "", postType: .photo, thumbnailImage: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, postURL: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, caption: "The Batman (2022)", likeCount: [PostLike(userName: "TheJoker", postIdentifier: "x"), PostLike(userName: "TheRiddler", postIdentifier: "x")], comments: comments, createDate: Date(), taggedUsers: [], owner: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: []))
        for _ in 0..<5{
            let viewModel = HomeRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: []))),
                                                post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                                                actions: PostRenderViewModel(renderType: .actions(provider: post)),
                                                likes: PostRenderViewModel(renderType: .likes(provider: post.likeCount)),
                                                caption: PostRenderViewModel(renderType: .caption(provider: post.caption ?? "")),
                                                comments: PostRenderViewModel(renderType: .comments(provider: post)))
            feedRenderModels.append(viewModel)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Home.likesSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Likes"
            guard let likesSafeData = likesData else{
                return
            }
            destinationVC.data = userData.convertPostLikesToUserRelationships(postLikes: likesSafeData)
        } else if segue.identifier == Constants.Home.postSegue{
            let destinationVC = segue.destination as! PostViewController
            destinationVC.model = postSegueModel
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate{
    
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRenderModels.count * 7
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = section
        if section == 0{
            return 1
        }
        else{
            let position = x % 7 == 0 ? x/7 : ((x - (x % 7)) / 7)
        }
        let subSection = x % 7
        if subSection == 1{
            // Header
            return 1
        } else if subSection == 2{
            // Post
            return 1
        } else if subSection == 3{
            // Actions
            return 1
        } else if subSection == 4{
            // Likes
            return 1
        }
        else if subSection == 5{
            // Caption
            return 1
        } else if subSection == 6{
            // Comments
            return 1
        } else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let x = indexPath.section
        let model: HomeRenderViewModel
        if x == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Home.logoCellIdentifier, for: indexPath) as! HomeLogoTableViewCell
            cell.delegate = self
            return cell
        } else {
            let position = x % 7 == 0 ? x/7 : ((x - (x % 7)) / 7)
            model = feedRenderModels[position]
        }
        let subSection = x % 7
        if subSection == 1 {
            // Header
            let headerModel = model.header
            switch headerModel.renderType {
            case .header(let user):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.headerCellIdentifier, for: indexPath) as! PostHeaderTableViewCell
                cell.configure(with: user)
                cell.delegate = self
                return cell
            case .actions, .primaryContent, .likes, .comments, .caption:
                return UITableViewCell()
            }
        } else if subSection == 2 {
            // Post
            let postModel = model.post
            switch postModel.renderType {
            case .primaryContent(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.postCellIdentifier, for: indexPath) as! PostTableViewCell
                cell.configure(with: post)
                return cell
            case .header, .actions, .likes, .comments, .caption:
                return UITableViewCell()
            }
        } else if subSection == 3 {
            // Actions
            let actionsModel = model.actions
            switch actionsModel.renderType {
            case .actions(let provider):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.actionsCellIdentifier, for: indexPath) as! PostActionsTableViewCell
                cell.configure(with: provider, userName: userData.userName)
                cell.delegate = self
                return cell
            case .header, .primaryContent, .likes, .comments, .caption:
                return UITableViewCell()
            }
        } 
        else if subSection == 4{
            // Likes
            let likesModel = model.likes
            switch likesModel.renderType{
            case .likes(let likes):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.likesCellIdentifier, for: indexPath) as! PostLikesTableViewCell
                cell.configure(with: likes)
                cell.delegate = self
                return cell
            case .header, .primaryContent, .actions, .comments, .caption:
                return UITableViewCell()
            }
        } else if subSection == 5{
            // Caption
            let  captionModel = model.caption
            switch captionModel.renderType{
            case .caption(let caption):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.captionCellIdentifier, for: indexPath) as! PostCaptionTableViewCell
                cell.configure(with: caption)
            case .header, .primaryContent, .actions, .likes, .comments: return UITableViewCell()
            }
        }
        else if subSection == 6 {
            // Comments
            let commentsModel = model.comments
            switch commentsModel.renderType{
            case .comments(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Home.commentsCellIdentifier, for: indexPath) as! HomeCommentsTableViewCell
                cell.configure(with: post)
                return cell
            case .header, .primaryContent, .actions, .likes, .caption: return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subSection = indexPath.section % 7
        if subSection == 0{
            return 40
        } else if subSection == 1{
            return 60
        } else if subSection == 2{
            return view.frame.width
        } else if subSection == 3{
            return 50
        } else if subSection == 4{
            return 30
        } else if subSection == 5{
            let position = indexPath.section % 7 == 0 ? indexPath.section / 7 : (indexPath.section - (indexPath.section % 7)) / 7
            let captionModel = feedRenderModels[position].caption
            switch captionModel.renderType {
            case .caption(let captionText):
                if captionText.count == 0{
                    return 0
                }
                return calculateHeightForCaption(captionText)
            default:
                return 30
            }
        } else if subSection == 6{
            return 50
        } else {
            return 0
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
extension HomeViewController: PostActionsTableViewCellDelegate{
    func didTapCommentButton(with model: UserPost) {
        self.postSegueModel = model
        self.performSegue(withIdentifier: Constants.Home.postSegue, sender: self)
    }
    func didTapLikeButton() {
        // Logic to like the post
    }
    
    func didTapSaveButton() {
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
