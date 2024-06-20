//
//  ProfileViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.settingsSegue, sender: self)
    }
    

}
