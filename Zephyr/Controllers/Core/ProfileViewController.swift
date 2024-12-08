//
//  ProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
import SkeletonView

class ProfileViewController: UIViewController {
    private var followerFollowingData = [UserRelationship]()
    private var postsData = [PostSummary]()
    private var videosData = [PostSummary]()
    private var savedPostsData = [PostSummary]()
    private var userData: UserModel?
    private var profileHeaderView: ProfileHeaderCollectionReusableView?
    
    var currentView = selectedView.posts
    private var postModel: PostSummary?
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userNameTitleBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        setupCollectionView()
        fetchUserData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    private func fetchUserData() {
        DispatchQueue.main.async {
            if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? ProfileHeaderCollectionReusableView {
                header.showSkeletonView()
            }
        }
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (fetchedUserData, success) in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? ProfileHeaderCollectionReusableView {
                    if success, let fetchedUserData = fetchedUserData {
                        self.userData = fetchedUserData
                        self.userNameTitleBarButton.title = self.userData?.userName
                        self.createPostsArray()
                        self.createSavedPostsArray()
                        header.hideSkeletons()
                        let indexSet = IndexSet(integer: 0)
                        self.collectionView.reloadSections(indexSet)
                    }
                }
                self.collectionView.reloadData()
                let indexSet = IndexSet(integer: 1)
                self.collectionView.reloadSections(indexSet)
                self.refreshControl.endRefreshing()
            }
        }
    }
    private func refreshUserData() {
        DispatchQueue.main.async {
            if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? ProfileHeaderCollectionReusableView {
                header.showSkeletonView()
            }
        }
        CurrentUserDataManager.shared.refreshUserData { [weak self] (fetchedUserData, success) in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? ProfileHeaderCollectionReusableView {
                    if success, let fetchedUserData = fetchedUserData {
                        self.userData = fetchedUserData
                        self.userNameTitleBarButton.title = self.userData?.userName
                        self.createPostsArray()
                        self.createSavedPostsArray()
                        header.hideSkeletons()
                        let indexSet = IndexSet(integer: 0)
                        self.collectionView.reloadSections(indexSet)
                    } else {
                        print("Failed to refresh user data")
                    }
                }
                self.collectionView.reloadData()
                let indexSet = IndexSet(integer: 1)
                self.collectionView.reloadSections(indexSet)
                self.refreshControl.endRefreshing()
                self.postsData.removeAll()
                self.videosData.removeAll()
            }
        }
    }
    private func createPostsArray() {
        guard let userData = userData else { return }
        var fetchedPosts: [String: PostSummary] = [:]
        let dispatchGroup = DispatchGroup()
        for postIdentifier in userData.posts {
            dispatchGroup.enter()
            fetchPostSummary(for: postIdentifier) { fetchedPost in
                defer {
                    dispatchGroup.leave()
                }
                if let fetchedPost = fetchedPost {
                    fetchedPosts[postIdentifier] = fetchedPost
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            var orderedPosts: [PostSummary] = []
            var orderedVideos: [PostSummary] = []
            for postIdentifier in userData.posts {
                if let fetchedPost = fetchedPosts[postIdentifier] {
                    orderedPosts.append(fetchedPost)
                    if fetchedPost.postType == .video{
                        orderedVideos.append(fetchedPost)
                    }
                }
            }
            self.postsData = orderedPosts
            self.videosData = orderedVideos
            self.collectionView.reloadData()
            let indexSet = IndexSet(integer: 1)
            self.collectionView.reloadSections(indexSet)
        }
    }
    
    private func createSavedPostsArray() {
        guard let userData = userData else { return }
        var fetchedPosts: [String: PostSummary] = [:]
        let dispatchGroup = DispatchGroup()

        for postIdentifier in userData.savedPosts {
            dispatchGroup.enter()
            fetchPostSummary(for: postIdentifier) { fetchedPost in
                defer {
                    dispatchGroup.leave()
                }
                if let fetchedPost = fetchedPost {
                    fetchedPosts[postIdentifier] = fetchedPost
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            var orderedSavedPosts: [PostSummary] = []
            for postIdentifier in userData.savedPosts {
                if let fetchedPost = fetchedPosts[postIdentifier] {
                    orderedSavedPosts.append(fetchedPost)
                }
            }
            self.savedPostsData = orderedSavedPosts
            self.collectionView.reloadData()
            let indexSet = IndexSet(integer: 1)
            self.collectionView.reloadSections(indexSet)
        }
    }

    func fetchPostSummary(for identifier: String, completion: @escaping (PostSummary?) -> Void){
        DatabaseManager.shared.fetchPostSummary(for: identifier){ fetchedPost in
            guard let fetchedPost = fetchedPost else{
                print("Failed to fetch post thumbnail for identifier: \(identifier)")
                completion(nil)
                return
            }
            completion(fetchedPost)
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
        refreshUserData()
    }
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        guard userData != nil else{
            return
        }
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
            case .savedPosts:
                return savedPostsData.count
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Profile.cellIdentifier, for: indexPath) as! ProfileCollectionViewCell
        var post: PostSummary?
        switch currentView {
        case .posts:
            if indexPath.row < postsData.count {
                post = postsData[indexPath.row]
            }
        case .videoPosts:
            post = videosData[indexPath.row]
        case .savedPosts:
            post = savedPostsData[indexPath.row]
        }
        if let post = post {
            cell.configure(with: post)
        }
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
            profileHeaderView = header
        }
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if let profileHeaderView = profileHeaderView {
                let height = profileHeaderView.calculateHeight()
                return CGSize(width: collectionView.frame.width, height: height)
            } else {
                return CGSize(width: collectionView.frame.width, height: 200)
            }
        } else {
            return CGSize(width: collectionView.frame.width, height: 65)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var post: PostSummary?
        switch currentView{
        case .posts:
            post = postsData[indexPath.row]
        case .videoPosts:
            post = videosData[indexPath.row]
        case .savedPosts:
            post = savedPostsData[indexPath.row]
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
    func profileHeaderDidTapEditProfileButton(_ header: ProfileHeaderCollectionReusableView) {
        self.performSegue(withIdentifier: Constants.Profile.editProfileSegue, sender: self)
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
                destinationVC.postIdentifier = postModel.identifier
            }
        } else if segue.identifier == Constants.Profile.settingsSegue{
            let destinationVC = segue.destination as! SettingsViewController
            destinationVC.userData = userData
        }
        else if segue.identifier == Constants.Profile.editProfileSegue{
            let destinationVC = segue.destination as! EditProfileViewController
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
    
    func didTapSavedPostsButton() {
        currentView = .savedPosts
        collectionView.reloadData()
    }
}
