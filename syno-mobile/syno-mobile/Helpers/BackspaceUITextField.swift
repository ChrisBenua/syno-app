//
//  BackspaceUITextField.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 16.07.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol IBackspaceUITextFieldDelegate: class {
    func onBackspace(sender: UITextField)
}

class BackspaceUITextField: UITextField {
    weak var backspaceDelegate: IBackspaceUITextFieldDelegate?
    
    override func deleteBackward() {
        backspaceDelegate?.onBackspace(sender: self)
        super.deleteBackward()
    }
}
