//
//  OTPViewController.swift
//  Zephyr
//
//  Created by Eclipse on 15/12/24.
//

import UIKit

class OTPViewController: UIViewController {
    
    @IBOutlet weak var txtOtp1: OTPTextField!
    @IBOutlet weak var txtOtp2: OTPTextField!
    @IBOutlet weak var txtOtp3: OTPTextField!
    @IBOutlet weak var txtOtp4: OTPTextField!
    @IBOutlet weak var submitOTPButton: UIButton!
    @IBOutlet weak var resendOTPButton: UIButton!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var countdownTime = 30
    var otpExpiryTime = 300
    var timer: Timer?
    var timer2: Timer?
    var OTP: String?
    var callerAction: String?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
        startCountDownTimer()
        startOTPExpiryTime()
        if let callerAction = callerAction {
            if callerAction == Constants.OTP.resetPassword{
                messageLabel.text = Constants.OTP.resetPasswordText
            }
        }
    }
    
    func setupFields() {
        txtOtp1.delegate = self
        txtOtp2.delegate = self
        txtOtp3.delegate = self
        txtOtp4.delegate = self
        
        txtOtp1.backDelegate = self
        txtOtp2.backDelegate = self
        txtOtp3.backDelegate = self
        txtOtp4.backDelegate = self
        
        enableField(txtOtp1)
        disableField(txtOtp2)
        disableField(txtOtp3)
        disableField(txtOtp4)
        
        resendOTPButton.isEnabled = false
        submitOTPButton.isEnabled = false
    }
    
    func enableField(_ field: OTPTextField) {
        field.isUserInteractionEnabled = true
        field.becomeFirstResponder()
    }
    
    func disableField(_ field: OTPTextField) {
        field.isUserInteractionEnabled = false
        field.resignFirstResponder()
    }
    
    func startCountDownTimer() {
        countdownLabel.text = "You can resend OTP in \(countdownTime) seconds"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    func startOTPExpiryTime() {
        timer2 = Timer.scheduledTimer(timeInterval: TimeInterval(otpExpiryTime), target: self, selector: #selector(expireOTP), userInfo: nil, repeats: false)
    }
    
    @objc func updateCountdown() {
        countdownTime -= 1
        countdownLabel.text = "Didn't receive the code? Resend in \(countdownTime) seconds"
        if countdownTime <= 0 {
            resendOTPButton.isEnabled = true
            countdownLabel.text = "You can request a new OTP now"
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func expireOTP() {
        OTP = nil
        timer2?.invalidate()
        timer2 = nil
        
        DispatchQueue.main.async {
            self.messageLabel.text = "The OTP has expired. Please request a new one."
            self.messageLabel.textColor = .red
            self.resendOTPButton.isEnabled = true
            self.submitOTPButton.isEnabled = false
        }
    }
    
    func resetOTPtextFields() {
        txtOtp1.text = ""
        txtOtp2.text = ""
        txtOtp3.text = ""
        txtOtp4.text = ""
        enableField(txtOtp1)
        disableField(txtOtp2)
        disableField(txtOtp3)
        disableField(txtOtp4)
    }
    
    @IBAction func resendOTPButtonPressed(_ sender: UIButton) {
        // Resend Logic
        guard let email = email else { return }
        OTPManager.shared.sendOTP(to: email) { success, OTP, error in
            if success, let safeOTP = OTP {
                DispatchQueue.main.async {
                    self.resetOTPtextFields()
                }
                self.OTP = safeOTP
                self.startOTPExpiryTime()
                DispatchQueue.main.async {
                    self.messageLabel.text = Constants.OTP.resendOTPText
                    self.messageLabel.textColor = UIColor(named: "ZephyrGray")
                    self.submitOTPButton.isEnabled = false
                }
            } else{
                DispatchQueue.main.async {
                    self.messageLabel.text = error
                    self.messageLabel.textColor = .red
                    self.resendOTPButton.isEnabled = true
                    self.submitOTPButton.isEnabled = false
                }
            }
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        // Submit Logic
        var enteredOTP = "\(txtOtp1.text ?? "")\(txtOtp2.text ?? "")\(txtOtp3.text ?? "")\(txtOtp4.text ?? "")"
        guard let safeEmail = email else {return}
        if let validOTP = OTP, enteredOTP == validOTP {
            AuthManager.shared.sendPasswordResetEmail(email: safeEmail) { success, error in
                if success {
                    print("Password reset email sent successfully!")
                    let alert = UIAlertController(title: "Success!", message: "Please check your email's inbox or the spam folder to find your reset password link.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
                        alert.dismiss(animated: true, completion: nil)
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                            loginVC.modalPresentationStyle = .fullScreen
                            self.present(loginVC, animated: true, completion: nil)
                        }
                    })
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("Failed to send password reset email: \(error ?? "Unknown error")")
                }
            }
        } else {
            messageLabel.text = "Invalid OTP. Please try again."
            messageLabel.textColor = .red
            resetOTPtextFields()
        }
    }
}

// MARK: - UITextFieldDelegate

extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let otpFields = [txtOtp1, txtOtp2, txtOtp3, txtOtp4] as? [OTPTextField] else { return false }
        guard let index = otpFields.firstIndex(of: textField as! OTPTextField) else { return false }
        
        if string.isEmpty {
            textField.text = ""
            submitOTPButton.isEnabled = false
            if index > 0 {
                let previousField = otpFields[index - 1]
                enableField(previousField)
                disableField(textField as! OTPTextField)
            }
        } else if let _ = Int(string) {
            textField.text = string
            if index < otpFields.count - 1 {
                let nextField = otpFields[index + 1]
                enableField(nextField)
                disableField(textField as! OTPTextField)
            } else {
                textField.resignFirstResponder()
                submitOTPButton.isEnabled = true
            }
        }
        return false
    }
}

// MARK: - OTPFieldDelegate
extension OTPViewController: OTPFieldDelegate {
    func backwardDetected(textField: OTPTextField) {
        guard let otpFields = [txtOtp1, txtOtp2, txtOtp3, txtOtp4] as? [OTPTextField] else { return }
        guard let index = otpFields.firstIndex(of: textField ) else { return }
        
        if index > 0 {
            let previousField = otpFields[index - 1]
            previousField.text = ""
            enableField(previousField)
            disableField(textField )
        }
    }
}
