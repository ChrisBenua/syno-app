//
//  RegisterState.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 04.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

@objc protocol IIsOkStateDelegate: class {
    func didOkStateChanged(isOk: Bool)
}

@objc protocol IRegisterState {
    var email: String { get }
    var password: String { get }
    var passwordConfirmation: String { get }
    var delegate: IIsOkStateDelegate? { get set }
    
    func isOk() -> Bool
    
    func emailTFDidChange(sender: UITextField)
    
    func passwordTFDidChange(sender: UITextField)
    
    func passwordConfTFDidChange(sender: UITextField)
}

class RegisterState: IRegisterState {
    @objc func emailTFDidChange(sender: UITextField) {
        self.email = sender.text!
        let _ = isOk()
    }
    
    @objc func passwordTFDidChange(sender: UITextField) {
        self.password = sender.text!
        let _ = isOk()
    }
    
    @objc func passwordConfTFDidChange(sender: UITextField) {
        self.passwordConfirmation = sender.text!
        let _ = isOk()
    }
    
    
    var email: String
    
    var password: String
    
    var passwordConfirmation: String
    
    weak var delegate: IIsOkStateDelegate?
    
    private var wasOk: Bool = false
    
    init() {
        self.email = ""
        self.password = ""
        self.passwordConfirmation = ""
    }
    
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
