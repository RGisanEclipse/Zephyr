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
    private var userData = UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "It's not who you are underneath, it's what you do, that defines you.", name: (first: "Bruce", last: "Wayne"), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: ["TheJoker"], following: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        configureModels()
        guard model != nil else {
            fatalError("Model is nil")
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.Post.headerCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.headerCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.postCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.postCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.actionsCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.actionsCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.likesCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.likesCellIdentifier)
        tableView.register(UINib(nibName: Constants.Post.generalCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.Post.generalCellIdentifier)
    }
    private func configureModels(){
        guard let userPostModel = self.model else{
            return
        }
        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.owner)))
        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))
        renderModels.append(PostRenderViewModel(renderType: .actions(provider: userPostModel)))
        renderModels.append(PostRenderViewModel(renderType: .likes(provider: userPostModel.likeCount)))
        var comments = [PostComment]()
        comments.append(PostComment(identifier: "x", user: UserModel(userName: "TheJoker", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/images/images/035/033/866/large/alexander-hodlmoser-square-color.jpg?1613934885")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: []), text: "Wanna know how I got that smile?", createdDate: Date(), likes: []))
        comments.append(PostComment(identifier: "y", user: UserModel(userName: "TheRiddler", profilePicture: URL(string: "https://cdna.artstation.com/p/assets/covers/images/006/212/068/large/william-gray-gotham-riddler-square.jpg?1496839509")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: []), text: "Let's meet at Iceberg Lounge :)", createdDate: Date(), likes: []))
        renderModels.append(PostRenderViewModel(renderType: .comments(comments: comments)))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Post.likesSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Likes"
            guard let likesSafeData = likesData else{
                return
            }
            destinationVC.data = userData.convertPostLikesToUserRelationships(postLikes: likesSafeData)
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
        case .comments(let comments): return comments.count > 4 ? 4 : comments.count
        case .header(_): return 1
        case .primaryContent(_): return 1
        case .likes(_): return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = renderModels[indexPath.section]
        switch model.renderType{
        case .actions(let actions):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.actionsCellIdentifier, for: indexPath) as! PostActionsTableViewCell
            cell.configure(with: actions, userName: userData.userName)
            return cell
        case .comments(let comments):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Post.generalCellIdentifier, for: indexPath) as! PostGeneralTableViewCell
            let comment = comments[indexPath.row]
            cell.configure(with: comment)
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
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = renderModels[indexPath.section]
        switch model.renderType{
        case .header(_): return 60
        case .actions(_): return 50
        case .primaryContent(_): return view.frame.width
        case .comments(_): return 60
        case .likes(_): return 30
        }
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

// MARK: - PostLikesTableViewCellDelegate
extension PostViewController: PostLikesTableViewCellDelegate{
    func didTapLikesButton(with likesData: [PostLike]) {
        self.likesData = likesData
        self.performSegue(withIdentifier: Constants.Post.likesSegue, sender: self)
    }
}
