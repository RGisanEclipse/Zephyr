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
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateErrors()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        updateErrors()
        let areFieldsEmpty = checkIfEmptyInputs()
        if areFieldsEmpty{
            throwError(Constants.Onboarding.emptyError)
        } else{
            // Login Logic
            loginButton.isEnabled = false
            var userName: String?
            var email: String?
            if emailTextField.text!.contains("@"), emailTextField.text!.contains("."){
                email = emailTextField.text!
                
            } else{
                userName = emailTextField.text!
            }
            AuthManager.shared.loginUser(userName: userName, email: email, password: passwordTextField.text!) { success in
                DispatchQueue.main.async{
                    if success{
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
                        self.throwError(Constants.Onboarding.invalidError)
                    }
                    self.loginButton.isEnabled = true
                }
            }
        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Onboarding.registerSegue, sender: self)
    }
    
    func throwError(_ text: String){
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
    
    func updateErrors(){
        errorLabel.isHidden = true
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
