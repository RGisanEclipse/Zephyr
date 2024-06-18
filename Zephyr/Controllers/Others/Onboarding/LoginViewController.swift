//
//  LoginViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toRegisterView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
