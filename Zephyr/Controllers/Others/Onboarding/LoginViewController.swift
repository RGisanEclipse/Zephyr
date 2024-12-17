//
//  LoginViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
import NVActivityIndicatorView
class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var dimmedView: UIView!
    @IBOutlet weak var spinner: NVActivityIndicatorView!
    @IBOutlet weak var registerButton: UIButton!
    var OTP: String?
    var segueEmail: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        updateErrors()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        forgotPasswordButton.isHidden = true
        dimmedView.isHidden = true
        spinner.type = .circleStrokeSpin
        spinner.color = .WB
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
                        self.forgotPasswordButton.isHidden = false
                    }
                    self.loginButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        updateErrors()
        emailTextField.text = Constants.empty
        passwordTextField.text = Constants.empty
        self.performSegue(withIdentifier: Constants.Onboarding.registerSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Onboarding.otpSegueLogin{
            let destinationVC = segue.destination as! OTPViewController
            destinationVC.OTP = self.OTP
            destinationVC.callerAction = Constants.OTP.resetPassword
            destinationVC.email = self.segueEmail
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        // Handle Forgot Password Scenario
        DispatchQueue.main.async {
            self.dimmedView.isHidden = false
            self.spinner.startAnimating()
            self.loginButton.isEnabled = false
            self.registerButton.isEnabled = false
        }
        
        guard let inputText = emailTextField.text, !inputText.isEmpty else {
            DispatchQueue.main.async {
                self.errorLabel.text = "Please enter your email/username & press forgot password"
                self.errorLabel.isHidden = false
                self.resetUI()
            }
            return
        }
        
        var userName: String?
        var email: String?
        if inputText.contains("@"), inputText.contains(".") {
            email = inputText
        } else {
            userName = inputText
        }
        
        AuthManager.shared.forgotPassword(userName: userName, email: email) { success, otp, error, email in
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.resetUI()
                if success, let safeOTP = otp, let safeEmail = email {
                    self.OTP = safeOTP
                    self.segueEmail = safeEmail
                    self.performSegue(withIdentifier: Constants.Onboarding.otpSegueLogin, sender: self)
                } else {
                    if let safeError = error{
                        self.throwError(safeError)
                    }
                }
            }
        }
        updateErrors()
        emailTextField.text = Constants.empty
        passwordTextField.text = Constants.empty
    }
    
    func resetUI() {
        spinner.stopAnimating()
        dimmedView.isHidden = true
        loginButton.isEnabled = true
        registerButton.isEnabled = true
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
