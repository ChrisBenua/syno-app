//
//  CommonUIElements.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 23.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit


class CommonUIElements {
    
    private static func layerSetup(view: UIView, borderWidth: CGFloat = 0.5, cornerRadius: CGFloat = 10,
                                   borderColor: CGColor = UIColor.gray.cgColor) {
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        
        view.layer.borderColor = UIColor.gray.cgColor
    }
    
    static func defaultTextField(borderWidth: CGFloat = 0.5, cornerRadius: CGFloat = 10,
                                 backgroundColor: UIColor = .textFieldsMainColor,
                                 borderColor: CGColor = UIColor.gray.cgColor,
                                 edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) -> UITextField {
        let textField = UITextFieldWithInsets(insets: edgeInsets)
        layerSetup(view: textField, borderWidth: borderWidth, cornerRadius: cornerRadius, borderColor: borderColor)
        textField.backgroundColor = backgroundColor
        
        return textField
    }
    
    static func defaultSubmitButton(text: String, cornerRadius: CGFloat = 15,
                                    backgroundColor: UIColor = .submitButtonMainColor,
                                    borderColor: CGColor = UIColor.gray.cgColor,
                                    textColor: UIColor = .black) -> UIButton {
        let button = UIButton(type: .custom)
        layerSetup(view: button, cornerRadius: cornerRadius, borderColor: borderColor)
        button.backgroundColor = backgroundColor

        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)

        return button
    }
}
