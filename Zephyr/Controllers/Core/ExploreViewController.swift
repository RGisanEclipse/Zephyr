//
//  ExploreViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ExploreViewController: UIViewController {
    
    private var postsData = [PostSummary]()
    private var postModel: PostSummary?
    private var refreshControl = UIRefreshControl()
    private var userData: UserModel?
    
    @IBOutlet weak var collectionView: UICollectionView!
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        collectionView.register(UINib(nibName: Constants.Profile.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Profile.cellIdentifier)
        navigationItem.searchController = searchController
        collectionView.dataSource = self
        collectionView.delegate = self
        for _ in 0..<30{
            postsData.append(PostSummary(identifier: "xyz", thumbnailImage: URL(string: "https://im.rediff.com/movies/2022/mar/04the-batman1.jpg?w=670&h=900")!, postType: .photo))
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl
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
}

// MARK: - UICollectionViewDataSource
extension ExploreViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Profile.cellIdentifier, for: indexPath) as! ProfileCollectionViewCell
        let post = postsData[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Explore.postSegue{
            let destinationVC = segue.destination as! PostViewController
            destinationVC.postIdentifier = postModel?.identifier
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ExploreViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = postsData[indexPath.row]
        self.postModel = post
        self.performSegue(withIdentifier: Constants.Explore.postSegue, sender: self)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExploreViewController: UICollectionViewDelegateFlowLayout{
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

// MARK: - UISearchBarDelegate

extension ExploreViewController: UISearchBarDelegate{}

