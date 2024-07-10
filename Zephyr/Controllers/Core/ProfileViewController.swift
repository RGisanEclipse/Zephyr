//
//  ProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

enum selectedView{
    case posts
    case videoPosts
    case taggedUserPosts
}

class ProfileViewController: UIViewController {
    private var testData = [UserRelationship]()
    private var postsData = [UserPost]()
    private var videosData = [UserPost]()
    private var taggedPostsData = [UserPost]()
    private var userData = UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "It's not who you are underneath, it's what you do, that defines you.", name: (first: "Bruce", last: "Wayne"), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 0, following: 0), joinDate: Date(), followers: [], following: [])
    var currentView = selectedView.posts
    private var postModel: UserPost?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userNameTitleBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: Constants.Profile.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Profile.cellIdentifier)
        collectionView.register(UINib(nibName: Constants.Profile.headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.Profile.headerIdentifier)
        collectionView.register(UINib(nibName: Constants.Profile.tabsIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.Profile.tabsIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        userNameTitleBarButton.title = userData.userName
        postsData.append(UserPost(identifier: "", postType: .photo, thumbnailImage: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, postURL: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, caption: nil, likeCount: [PostLike(userName: "TheJoker", postIdentifier: "x"), PostLike(userName: "TheRiddler", postIdentifier: "x")], comments: [], createDate: Date(), taggedUsers: [], owner: UserModel(userName: "TheBatman", profilePicture: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3yWDu-i3sbrtGUoAnYqKyZcf-RbSRqsRtYg&s")!, bio: "", name: (first: "", last: ""), birthDate: Date(), gender: .male, counts: UserCount(posts: 1, followers: 1, following: 1), joinDate: Date(), followers: [], following: [])))
    }
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Profile.settingsSegue, sender: self)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 0
        } else{
            switch currentView{
            case .posts:
                return postsData.count
            case .videoPosts:
                return videosData.count
            case .taggedUserPosts:
                return taggedPostsData.count
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Profile.cellIdentifier, for: indexPath) as! ProfileCollectionViewCell
        var post: UserPost
        switch currentView{
        case .posts:
            post = postsData[indexPath.row]
        case .videoPosts:
            post = videosData[indexPath.row]
        case .taggedUserPosts:
            post = taggedPostsData[indexPath.row]
        }
        cell.configure(with: post)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else{
            return UICollectionReusableView()
        }
        if indexPath.section == 1{
            let tab = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Profile.tabsIdentifier, for: indexPath) as! ProfileTabsCollectionReusableView
            tab.delegate = self
            return tab
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Profile.headerIdentifier, for: indexPath) as! ProfileHeaderCollectionReusableView
        header.configure(with: userData)
        header.delegate = self
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height/3)
        } else{
            return CGSize(width: collectionView.frame.width, height: 65)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var post: UserPost?
        switch currentView{
        case .posts:
            post = postsData[indexPath.row]
        case .videoPosts:
            post = videosData[indexPath.row]
        case .taggedUserPosts:
            post = taggedPostsData[indexPath.row]
        }
        self.postModel = post
        self.performSegue(withIdentifier: Constants.Profile.postSegue, sender: self)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        return CGSize(width: collectionViewWidth/3 - 1, height: collectionViewWidth/3 - 1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

// MARK: - ProfileHeaderCollectionReusableViewDelegate
extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate{
    func profileHeaderDidTapPostsButton(_ header: ProfileHeaderCollectionReusableView) {
        let section = 1
        let row = 0
        if collectionView.numberOfSections > section {
            if collectionView.numberOfItems(inSection: section) > row {
                collectionView.scrollToItem(at: IndexPath(row: row, section: section), at: .top, animated: true)
            } else {
                return
            }
        } else {
            return
        }
    }
    func profileHeaderDidTapFollowersButton(_ header: ProfileHeaderCollectionReusableView) {
        self.performSegue(withIdentifier: Constants.Profile.followersSegue, sender: self)
    }
    
    func profileHeaderDidTapFollowingButton(_ header: ProfileHeaderCollectionReusableView) {
        self.performSegue(withIdentifier: Constants.Profile.followingSegue, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Profile.followersSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Followers"
            destinationVC.data = testData
        } else if segue.identifier == Constants.Profile.followingSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Following"
            destinationVC.data = testData
        } else if segue.identifier == Constants.Profile.postSegue{
            let destinationVC = segue.destination as! PostViewController
            destinationVC.model = postModel!
        } else if segue.identifier == Constants.Profile.settingsSegue{
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.userData = userData
        }
    }
}

// MARK: -
extension ProfileViewController: ProfileTabsCollectionReusableViewDelegate{
    func didTapPostsButton() {
        currentView = .posts
        collectionView.reloadData()
    }
    
    func didTapVideoPostsButton() {
        currentView = .videoPosts
        collectionView.reloadData()
    }
    
    func didTapTaggedUserPostsButton() {
        currentView = .taggedUserPosts
        collectionView.reloadData()
    }
}
