//
//  LoginViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ueInvalidLabel: UILabel!
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ueInvalidLabel.isHidden = true
        wrongPasswordLabel.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let safeEmailText = emailTextField.text, !safeEmailText.isEmpty{
            if let safePassword = passwordTextField.text, !safePassword.isEmpty{
            } else{
                wrongPasswordLabel.text = Constants.Onboarding.emptyError
                wrongPasswordLabel.isHidden = false
            }
        } else{
            ueInvalidLabel.text = Constants.Onboarding.emptyError
            ueInvalidLabel.isHidden = false
        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Onboarding.registerSegue, sender: self)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ueInvalidLabel.isHidden = true
        wrongPasswordLabel.isHidden = true
    }
    
    private func textFieldShouldEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
