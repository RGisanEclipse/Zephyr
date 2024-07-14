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
    private var followerFollowingData = [UserRelationship]()
    private var postsData = [UserPost]()
    private var videosData = [UserPost]()
    private var taggedPostsData = [UserPost]()
    private var userData: UserModel?

    var currentView = selectedView.posts
    private var postModel: UserPost?
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userNameTitleBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchUserData()
    }
    func fetchUserData() {
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (fetchedUserData, success) in
            guard let self = self else { return }
            if success, let fetchedUserData = fetchedUserData {
                self.userData = fetchedUserData
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.userNameTitleBarButton.title = self.userData?.userName
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                print("Error fetching userData")
            }
        }
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: Constants.Profile.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Profile.cellIdentifier)
        collectionView.register(UINib(nibName: Constants.Profile.headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.Profile.headerIdentifier)
        collectionView.register(UINib(nibName: Constants.Profile.tabsIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.Profile.tabsIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }

    @objc private func refreshData(_ sender: Any) {
        fetchUserData()
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
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        if indexPath.section == 1 {
            let tab = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Profile.tabsIdentifier, for: indexPath) as! ProfileTabsCollectionReusableView
            tab.delegate = self
            return tab
        }

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Profile.headerIdentifier, for: indexPath) as! ProfileHeaderCollectionReusableView
        if let userData = self.userData {
            header.configure(with: userData)
        }
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
        guard let userData = self.userData else {
            self.followerFollowingData = []
            self.performSegue(withIdentifier: Constants.Profile.followersSegue, sender: self)
            return
        }
        self.followerFollowingData = userData.convertFollowerToUserRelationships(with: userData.followers)
        self.performSegue(withIdentifier: Constants.Profile.followersSegue, sender: self)
    }


    
    func profileHeaderDidTapFollowingButton(_ header: ProfileHeaderCollectionReusableView) {
        guard let userData = self.userData else{
            self.followerFollowingData = []
            self.performSegue(withIdentifier: Constants.Profile.followingSegue, sender: self)
            return
        }
        self.followerFollowingData = userData.convertFollowerToUserRelationships(with: userData.following)
        self.performSegue(withIdentifier: Constants.Profile.followingSegue, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Profile.followersSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Followers"
            destinationVC.data = followerFollowingData
        } else if segue.identifier == Constants.Profile.followingSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Following"
            destinationVC.data = followerFollowingData
        } else if segue.identifier == Constants.Profile.postSegue{
            let destinationVC = segue.destination as! PostViewController
                if let postModel = postModel {
                    destinationVC.model = postModel
                }
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
