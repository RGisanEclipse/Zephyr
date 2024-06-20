//
//  SplashScreenViewController.swift
//  Zephyr
//
//  Created by Eclipse on 21/06/24.
//
import FirebaseAuth
import UIKit

class SplashScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Checking Authentication Status
            if Auth.auth().currentUser == nil{
                self.performSegue(withIdentifier: Constants.Onboarding.launchLoginSegue, sender: self)
            } else{
                self.performSegue(withIdentifier: Constants.Onboarding.launchHomeSegue, sender: self)
            }
        }
    }
}
