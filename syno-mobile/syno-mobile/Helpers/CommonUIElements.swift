import Foundation
import UIKit

/// Class for creating common UIElements
class CommonUIElements {
    
    /**
     Setups view's layer
     - Parameter view: View which layer will be modified
     - Parameter borderWidth: width of border around view
     - Parameter cornerRadius: Radius of corners of view
     - Parameter borderColor: border color
     */
    private static func layerSetup(view: UIView, borderWidth: CGFloat = 0.5, cornerRadius: CGFloat = 10,
                                   borderColor: CGColor = UIColor.gray.cgColor) {
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        
        view.layer.borderColor = UIColor.gray.cgColor
    }
    
    /// Generates TextField with given parameters(default for default TextField)
    static func defaultTextField(borderWidth: CGFloat = 0.5, cornerRadius: CGFloat = 10,
                                 backgroundColor: UIColor = .textFieldsMainColor,
                                 borderColor: CGColor = UIColor.gray.cgColor,
                                 edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) -> UITextField {
        let textField = UITextFieldWithInsets(insets: edgeInsets)
        layerSetup(view: textField, borderWidth: borderWidth, cornerRadius: cornerRadius, borderColor: borderColor)
        textField.backgroundColor = backgroundColor
        
        return textField
    }
    
    /// Generates UIButton with given parameters(default for default button)
    static func defaultSubmitButton(text: String, cornerRadius: CGFloat = 15,
                                    backgroundColor: UIColor = .submitButtonMainColor,
                                    borderColor: CGColor = UIColor.gray.cgColor,
                                    textColor: UIColor = .black, type: UIButton.ButtonType = .custom) -> UIButton {
        let button = UIButton(type: type)
        layerSetup(view: button, cornerRadius: cornerRadius, borderColor: borderColor)
        button.backgroundColor = backgroundColor

        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)

        return button
    }
}
