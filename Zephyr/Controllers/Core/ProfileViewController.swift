//
//  ProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameButton: UIBarButtonItem!
    @IBOutlet weak var profilePictureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.size.width / 2
        profilePictureButton.layer.borderWidth = 1
        profilePictureButton.layer.borderColor = CGColor.init(red: 90, green: 90, blue: 90, alpha: 1)
        profilePictureButton.layer.masksToBounds = true
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.settingsSegue, sender: self)
    }
    

}
