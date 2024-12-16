//
//  OTPTextField.swift
//  Zephyr
//
//  Created by Eclipse on 15/12/24.
//

import Foundation
import UIKit

protocol OTPFieldDelegate: AnyObject {
   func backwardDetected(textField: OTPTextField)
}

class OTPTextField: UITextField {
    weak var backDelegate: OTPFieldDelegate?

   override func deleteBackward() {
     super.deleteBackward()
     self.backDelegate?.backwardDetected(textField: self)
   }
}
