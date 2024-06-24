//
//  ProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var selectedButton: UIButton?
    var postsData = [String]()
    var videosData = [String]()
    var taggedPostsData = [String]()
    
    @IBOutlet weak var userNameButton: UIBarButtonItem!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var videosButton: UIButton!
    @IBOutlet weak var taggedPostsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
        collectionView.register(UINib(nibName: Constants.Profile.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.Profile.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        selectButton(postsButton)
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.settingsSegue, sender: self)
    }
    
    @IBAction func postsButtonPressed(_ sender: UIButton) {
        selectButton(sender)
        collectionView.reloadData()
    }
    @IBAction func videosButtonPressed(_ sender: UIButton) {
        selectButton(sender)
        collectionView.reloadData()
    }
    
    @IBAction func taggedPostsButtonPressed(_ sender: UIButton) {
        selectButton(sender)
        collectionView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Profile.followersSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Followers"
        } else if segue.identifier == Constants.Profile.followingSegue{
            let destinationVC = segue.destination as! ListViewController
            destinationVC.viewTitle = "Following"
        }
    }
    private func selectButton(_ button: UIButton) {
       selectedButton = button
   }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedButton == postsButton {
            return postsData.count
        } else if selectedButton == videosButton {
            return videosData.count
        } else if selectedButton == taggedPostsButton {
            return taggedPostsData.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Profile.cellIdentifier, for: indexPath) as! ProfileCollectionViewCell
        var imageURLString = ""
        if selectedButton == postsButton {
            imageURLString = postsData[indexPath.item]
        } else if selectedButton == videosButton {
            imageURLString = videosData[indexPath.item]
        } else if selectedButton == taggedPostsButton {
            imageURLString = taggedPostsData[indexPath.item]
        }
        if let imageURL = URL(string: imageURLString){
            cell.configure(with: imageURL)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController:UICollectionViewDelegateFlowLayout{
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
