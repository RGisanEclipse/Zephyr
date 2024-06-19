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
        let areFieldsEmpty = checkIfEmptyInputs()
        if areFieldsEmpty{
            throwEmptyError(Constants.Onboarding.emptyError)
        } else{
            // Login Logic
        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Onboarding.registerSegue, sender: self)
    }
    
    func throwEmptyError(_ text: String){
        errorLabel.text = text
        errorLabel.isHidden = false
    }
    
    func checkIfEmptyInputs()->Bool{
        guard
            let safeEmail = emailTextField.text, !safeEmail.isEmpty,
            let safePassword = passwordTextField.text, !safePassword.isEmpty
        else {
            return true
        }
        return false
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
