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
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
        startCountDownTimer()
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
    
    @objc func updateCountdown() {
        countdownTime -= 1
        countdownLabel.text = "Didn't receive the code? Resend in \(countdownTime) seconds"
        if countdownTime <= 0 {
            resendOTPButton.isEnabled = true
            countdownLabel.text = "You can resend the OTP now"
            timer?.invalidate()
            timer = nil
        }
    }
    
    @IBAction func resendOTPButtonPressed(_ sender: UIButton) {
        // Resend Logic
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        // Submit Logic
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
