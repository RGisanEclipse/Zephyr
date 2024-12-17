//
//  RegisterViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        updateErrors()
        let areFieldsEmpty = checkIfEmptyInputs()
        if areFieldsEmpty{
            throwError(Constants.Onboarding.emptyError)
        } else{
            let password = passwordTextField.text
            if password!.count < 8{
                throwError(Constants.Onboarding.smallPasswordError)
            } else if passwordTextField.text!.count > 32 {
                throwError(Constants.Onboarding.largePasswordError)
            } else {
                let password = passwordTextField.text!
                let uppercaseRegex = ".*[A-Z]+.*"
                let lowercaseRegex = ".*[a-z]+.*"
                let digitRegex = ".*[0-9]+.*"
                let specialCharacterRegex = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
                let repeatedRegex = ".*(.)\\1{2,}.*"
                let commonPasswords = PasswordManager.getCommonPasswords()
                let whitespaceRegex = ".*\\s+.*"
                
                if !NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: password) {
                    throwError(Constants.Onboarding.noUppercaseError)
                } else if !NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: password) {
                    throwError(Constants.Onboarding.noLowercaseError)
                } else if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) {
                    throwError(Constants.Onboarding.noNumberError)
                } else if !NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex).evaluate(with: password) {
                    throwError(Constants.Onboarding.noSpecialCharacterError)
                } else if NSPredicate(format: "SELF MATCHES %@", repeatedRegex).evaluate(with: password) {
                    throwError(Constants.Onboarding.repeatedCharacterError)
                } else if commonPasswords.contains(password) {
                    throwError(Constants.Onboarding.commonPasswordError)
                } else if NSPredicate(format: "SELF MATCHES %@", whitespaceRegex).evaluate(with: password) {
                    throwError(Constants.Onboarding.containsWhitespaceError)
                } else {
                    registerButton.isEnabled = false
                    AuthManager.shared.registerNewUser(userName: userNameTextField.text!, email: emailTextField.text!, password: password) { registered, error in
                        if registered{
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                                    tabBarVC.modalPresentationStyle = .fullScreen
                                    self.present(tabBarVC, animated: true, completion: nil)
                                } else {
                                    print("HomeViewController could not be instantiated")
                                }
                            }
                        } else{
                            if let error = error as NSError? {
                                self.throwError(error.domain)
                            }
                        }
                        self.registerButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func throwError(_ text: String){
        errorLabel.text = text
        errorLabel.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateErrors()
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func checkIfEmptyInputs()->Bool{
        guard
            let safeUsername = userNameTextField.text, !safeUsername.isEmpty,
            let safeEmail = emailTextField.text, !safeEmail.isEmpty,
            let safePassword = passwordTextField.text, !safePassword.isEmpty
        else {
            return true
        }
        return false
    }
    
    func updateErrors(){
        errorLabel.isHidden = true
    }
    
}
// MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    private func textFieldShouldEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField{
            textField.resignFirstResponder()
        }
        return true
    }
}
