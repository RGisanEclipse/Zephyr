//
//  LoginViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = Constants.Onboarding.emptyError
            errorLabel.isHidden = false
                return
            }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Onboarding.registerSegue, sender: self)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.isHidden = true
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
