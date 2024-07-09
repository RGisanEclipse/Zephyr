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
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        createMockModels()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.Post.headerCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.headerCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.postCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.postCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.actionsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.actionsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.generalCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.generalCellIdentifier)
        tableView.register(UINib(nibName: Constants.Home.logoCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Home.logoCellIdentifier)
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
        let post = UserPost(identifier: "", postType: .video, thumbnailImage: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYVx6CB56pxO8gwlzLLOkV8fPN0jfF3T_98w&s")!, postURL: URL(string: "https://videos.pexels.com/video-files/3343679/3343679-hd_1920_1080_30fps.mp4")!, caption: nil, likeCount: [], comments: [], createDate: Date(), taggedUsers: [], owner: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://pbs.twimg.com/profile_images/1676116130275143680/BkUKyvp7_400x400.jpg")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date()))
        var comments = [PostComment]()
        comments.append(PostComment(identifier: "x", user: UserModel(userName: "TheJoker", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/images/images/035/033/866/large/alexander-hodlmoser-square-color.jpg?1613934885")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date()), text: "Great Post!", createdDate: Date(), likes: []))
        comments.append(PostComment(identifier: "y", user: UserModel(userName: "TheRiddler", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/covers/images/006/212/068/large/william-gray-gotham-riddler-square.jpg?1496839509")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date()), text: "Let's meet at IceBerg Lounge :)", createdDate: Date(), likes: []))
        for _ in 0..<5{
            let viewModel = HomeRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date()))),
                                                post: PostRenderViewModel(renderType: .primaryContent(provider: post)),
                                                actions: PostRenderViewModel(renderType: .actions(provider: "")),
                                                comments: PostRenderViewModel(renderType: .comments(comments: comments)))
            feedRenderModels.append(viewModel)
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate{
    
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRenderModels.count * 4 + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = section
        let model: HomeRenderViewModel
        if section == 0{
            return 1
        }
        else{
            let position = x % 5 == 0 ? x/5 : ((x - (x % 5)) / 5)
            model = feedRenderModels[position]
        }
        let subSection = x % 5
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
            // Comments
            let commentModel = model.comments
            switch commentModel.renderType{
            case .comments(comments: let comments): return comments.count > 2 ? 2 : comments.count
            case .header, .actions, .primaryContent: return 0
            }
        } else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let x = indexPath.section
        let model: HomeRenderViewModel
        if x == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Home.logoCellIdentifier, for: indexPath)
            return cell
        } else {
            let position = x % 5 == 0 ? x/5 : ((x - (x % 5)) / 5)
            model = feedRenderModels[position]
        }
        let subSection = x % 5
        if subSection == 1 {
            // Header
            let headerModel = model.header
            switch headerModel.renderType {
            case .header(let user):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.headerCellIdentifier, for: indexPath) as! PostHeaderTableViewCell
                cell.configure(with: user)
                cell.delegate = self
                return cell
            case .actions, .primaryContent, .comments:
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
            case .header, .actions, .comments:
                return UITableViewCell()
            }
        } else if subSection == 3 {
            // Actions
            let actionsModel = model.actions
            switch actionsModel.renderType {
            case .actions(let provider):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.actionsCellIdentifier, for: indexPath) as! PostActionsTableViewCell
                cell.delegate = self
                return cell
            case .header, .primaryContent, .comments:
                return UITableViewCell()
            }
        } else if subSection == 4 {
            // Comments
            let commentModel = model.comments
            switch commentModel.renderType {
            case .comments(let comments):
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.generalCellIdentifier, for: indexPath) as! PostGeneralTableViewCell
                let comment = comments[indexPath.row] // Get the specific comment for this row
                cell.configure(with: comment) // Configure cell with comment data
                return cell
            case .header, .primaryContent, .actions:
                return UITableViewCell()
            }
        } else {
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subSection = indexPath.section % 5
        if subSection == 0{
            return 40
        } else if subSection == 1{
            return 60
        } else if subSection == 2{
            return view.frame.width
        } else if subSection == 3{
            return 50
        } else if subSection == 4{
            return 70
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let subSection = section % 5
        return subSection == 4 ? 30 : 0
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
        let subSection = indexPath.section % 5
        if subSection == 2{
            if let postCell = cell as? PostTableViewCell {
                postCell.pauseVideo()
                postCell.muteVideo()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
}

// MARK: - PostActionsTableViewCellDelegate
extension HomeViewController: PostActionsTableViewCellDelegate{
    func didTapLikeButton() {
        // Logic to like the post
    }
    func didTapCommentButton() {
        // Logic to comment on the post
    }
    func didTapSaveButton() {
        // Logic to save the post
    }
}

