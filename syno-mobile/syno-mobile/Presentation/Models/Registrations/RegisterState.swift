import Foundation
import UIKit

/// Protocol for checking state of registration form
@objc protocol IIsOkStateDelegate: class {
    /// Notifies when correctness of registration form changed
    func didOkStateChanged(isOk: Bool)
}

@objc protocol IRegisterState {
    /// User email
    var email: String { get }
    /// User's password
    var password: String { get }
    /// User's password confirmation
    var passwordConfirmation: String { get }
    /// Event handler
    var delegate: IIsOkStateDelegate? { get set }
    
    /// Checks if registration form is correct
    func isOk() -> Bool
    
    /// Used to notify when email text field changes
    func emailTFDidChange(sender: UITextField)
    
    /// Used to notify when password text field changes
    func passwordTFDidChange(sender: UITextField)
    
    /// Used to notify when password confirmation text field changes
    func passwordConfTFDidChange(sender: UITextField)
}

class RegisterState: IRegisterState {
    private func check(textField: UITextField) {
        if ((textField.text?.count ?? 0) > 100) {
            textField.text = String(textField.text![..<textField.text!.index(textField.text!.startIndex, offsetBy: 100)])
        }
    }
    @objc func emailTFDidChange(sender: UITextField) {
        check(textField: sender)
        self.email = sender.text!
        let _ = isOk()
    }
    
    @objc func passwordTFDidChange(sender: UITextField) {
        check(textField: sender)
        self.password = sender.text!
        let _ = isOk()
    }
    
    @objc func passwordConfTFDidChange(sender: UITextField) {
        check(textField: sender)
        self.passwordConfirmation = sender.text!
        let _ = isOk()
    }
    
    var email: String
    
    var password: String
    
    var passwordConfirmation: String
    
    weak var delegate: IIsOkStateDelegate?
    
    private var wasOk: Bool = false
    
    /**
     Creates new empty `RegisterState`
     */
    init() {
        self.email = ""
        self.password = ""
        self.passwordConfirmation = ""
    }
    
    /**
    Creates new  `RegisterState`
     - Parameter email: Current entered email
     - Parameter password: Current entered password
     - Parameter passwordConfirmation: Current entered password confirmation
    */
    init(email: String, password: String, passwordConfirmation: String) {
        self.email = email
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
    
    func isOk() -> Bool {
        let splittedComponents = email.components(separatedBy: CharacterSet(charactersIn: "@."))
        let _isOk = email.count >= 4 && email.contains("@") && splittedComponents.count >= 3 && passwordConfirmation.count > 0 && passwordConfirmation == password
        
        if _isOk != wasOk {
            wasOk = _isOk
            delegate?.didOkStateChanged(isOk: wasOk)
        }
        
        return _isOk
    }
}
