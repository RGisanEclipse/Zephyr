//
//  UserProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 07/08/24.
//

import UIKit
import SkeletonView
class UserProfileViewController: UIViewController {
   
    private var currentUserData: UserModel?
    var segueUserName: String?
    private var followerFollowingData = [UserRelationship]()
    private var postsData = [PostSummary]()
    private var videosData = [PostSummary]()
    private var taggedPostsData = [PostSummary]()
    private var userData: UserModel?
    private var profileHeaderView: UserProfileHeaderCollectionReusableView?
    
    var currentView = selectedView.posts
    private var postModel: PostSummary?
    private var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        setupCollectionView()
        fetchUserData()
        fetchCurrentUserData()
    }
    private func fetchCurrentUserData(){
        CurrentUserDataManager.shared.fetchLoggedInUserData { [weak self] (user, success) in
            guard let self = self, success, let user = user else {
                return
            }
            self.currentUserData = user
        }
    }
    private func fetchUserData() {
        DispatchQueue.main.async {
            if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? UserProfileHeaderCollectionReusableView {
                header.showSkeletonView()
            }
        }
        guard let safeSegueUserName = segueUserName else { return }
        UserDataManager.shared.fetchUserData(with: safeSegueUserName) { [weak self] (fetchedUserData, success) in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? UserProfileHeaderCollectionReusableView {
                    if success, let fetchedUserData = fetchedUserData {
                        self.userData = fetchedUserData
                        self.navigationItem.title = fetchedUserData.userName
                        self.createPostsArray()
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
    private func refreshUserData() {
        DispatchQueue.main.async {
            if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? UserProfileHeaderCollectionReusableView {
                header.showSkeletonView()
            }
        }
        guard let safeSegueUserName = segueUserName else { return }
        UserDataManager.shared.fetchUserData(with: safeSegueUserName) { [weak self] (fetchedUserData, success) in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? UserProfileHeaderCollectionReusableView {
                    if success, let fetchedUserData = fetchedUserData {
                        self.userData = fetchedUserData
                        self.createPostsArray()
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
    @objc private func refreshData(_ sender: Any) {
        refreshUserData()
    }
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: Constants.Profile.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Profile.cellIdentifier)
        collectionView.register(UINib(nibName: Constants.Profile.headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.Profile.headerIdentifier)
        collectionView.register(UINib(nibName: Constants.UserProfile.headerIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.UserProfile.headerIdentifier)
        collectionView.register(UINib(nibName: Constants.Profile.tabsIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.Profile.tabsIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.UserProfile.followersSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Followers"
            destinationVC.data = followerFollowingData
        } else if segue.identifier == Constants.UserProfile.followingSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Following"
            destinationVC.data = followerFollowingData
        } else if segue.identifier == Constants.UserProfile.postSegue{
            let destinationVC = segue.destination as! PostViewController
            if let postModel = postModel {
                destinationVC.postIdentifier = postModel.identifier
            }
        } else if segue.identifier == Constants.UserProfile.editProfileSegue{
            let destinationVC = segue.destination as! EditProfileViewController
            destinationVC.userData = userData
        }
    }
}

// MARK: - UICollectionViewDataSource
extension UserProfileViewController: UICollectionViewDataSource{
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
        var post: PostSummary?
        switch currentView {
        case .posts:
            if indexPath.row < postsData.count {
                post = postsData[indexPath.row]
            }
        case .videoPosts:
            post = videosData[indexPath.row]
        case .taggedUserPosts:
            post = taggedPostsData[indexPath.row]
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
        if let currentUserData = currentUserData, let userData = userData, currentUserData.userName == userData.userName {
            let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Profile.headerIdentifier, for: indexPath) as! ProfileHeaderCollectionReusableView
            profileHeader.configure(with: userData)
            profileHeader.delegate = self
            return profileHeader
        } else {
            let userProfileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.UserProfile.headerIdentifier, for: indexPath) as! UserProfileHeaderCollectionReusableView
            if let userData = self.userData {
                if let currentUserData = self.currentUserData{
                    var doesFollow = userData.isFollower(userName: currentUserData.userName)
                    userProfileHeader.configure(with: userData, doesFollow: true)
                    profileHeaderView = userProfileHeader
                }
            }
            userProfileHeader.delegate = self
            return userProfileHeader
        }
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
extension UserProfileViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var post: PostSummary?
        switch currentView{
        case .posts:
            post = postsData[indexPath.row]
        case .videoPosts:
            post = videosData[indexPath.row]
        case .taggedUserPosts:
            post = taggedPostsData[indexPath.row]
        }
        self.postModel = post
        self.performSegue(withIdentifier: Constants.UserProfile.postSegue, sender: self)
    }
}

// MARK: - ProfileTabsCollectionViewDelegate
extension UserProfileViewController: ProfileTabsCollectionReusableViewDelegate{
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

// MARK: - UICollectionViewDelegateFlowLayout
extension UserProfileViewController: UICollectionViewDelegateFlowLayout{
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

// MARK: - ProfileHeaderCollectionViewDelegate
extension UserProfileViewController: UserProfileHeaderCollectionReusableViewDelegate{
    func userProfileHeaderDidTapFollowButton(_ header: UserProfileHeaderCollectionReusableView) {
        print("Tapped Follow/Unfollow Button")
    }
    func userProfileHeaderDidTapPostsButton(_ header: UserProfileHeaderCollectionReusableView) {
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
    func userProfileHeaderDidTapFollowersButton(_ header: UserProfileHeaderCollectionReusableView) {
        guard let userData = self.userData else {
            self.followerFollowingData = []
            self.performSegue(withIdentifier: Constants.UserProfile.followersSegue, sender: self)
            return
        }
        self.followerFollowingData = userData.convertFollowerToUserRelationships(with: userData.followers)
        self.performSegue(withIdentifier: Constants.UserProfile.followersSegue, sender: self)
    }
    func userProfileHeaderDidTapFollowingButton(_ header: UserProfileHeaderCollectionReusableView) {
        guard let userData = self.userData else{
            self.followerFollowingData = []
            self.performSegue(withIdentifier: Constants.UserProfile.followingSegue, sender: self)
            return
        }
        self.followerFollowingData = userData.convertFollowerToUserRelationships(with: userData.following)
        self.performSegue(withIdentifier: Constants.UserProfile.followingSegue, sender: self)
    }
    func profileHeaderDidTapEditProfileButton(_ header: UserProfileHeaderCollectionReusableView) {
        self.performSegue(withIdentifier: Constants.Profile.editProfileSegue, sender: self)
    }
}

extension UserProfileViewController: ProfileHeaderCollectionReusableViewDelegate{
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
            self.performSegue(withIdentifier: Constants.UserProfile.followersSegue, sender: self)
            return
        }
        self.followerFollowingData = userData.convertFollowerToUserRelationships(with: userData.followers)
        self.performSegue(withIdentifier: Constants.UserProfile.followersSegue, sender: self)
    }
    func profileHeaderDidTapFollowingButton(_ header: ProfileHeaderCollectionReusableView) {
        guard let userData = self.userData else{
            self.followerFollowingData = []
            self.performSegue(withIdentifier: Constants.UserProfile.followingSegue, sender: self)
            return
        }
        self.followerFollowingData = userData.convertFollowerToUserRelationships(with: userData.following)
        self.performSegue(withIdentifier: Constants.UserProfile.followingSegue, sender: self)
    }
    func profileHeaderDidTapEditProfileButton(_ header: ProfileHeaderCollectionReusableView) {
        self.performSegue(withIdentifier: Constants.UserProfile.editProfileSegue, sender: self)
    }
}
