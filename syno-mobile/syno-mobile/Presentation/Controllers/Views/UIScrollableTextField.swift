import Foundation
import UIKit

class UIScrollableTextField: UIView {
    var textField: UITextField
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var isEditing: Bool {
        return textField.isEditing
    }
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.addSubview(textField)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        textField.anchor(top: nil, left: sv.leftAnchor, bottom: nil, right: sv.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        textField.centerYAnchor.constraint(equalTo: sv.centerYAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 1).isActive = true
        
        return sv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Logger.log("scrollView \(textField.frame)")
        //Logger.log("textfield \(textField.frame)")
    }
    
    init(textField: UITextField) {
        self.textField = textField

        super.init(frame: .zero)
        self.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        textField.widthAnchor.constraint(greaterThanOrEqualTo: self.widthAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
