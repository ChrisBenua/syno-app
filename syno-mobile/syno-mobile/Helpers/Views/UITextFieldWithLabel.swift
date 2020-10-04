import Foundation
import UIKit


class UIViewWithLabel: UIView {
    /// Actual TextField
    private var view: UIView
    /// Actual Label
    private var label: UILabel
    /// Spacing between Label and TextField
    private var spacing: CGFloat
    
    /// Layouts views inside `UITextFieldWithLabel`
    private func layout() {
        let sv = UIStackView(arrangedSubviews: [label, view])
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.spacing = spacing
        
        self.addSubview(sv)
        sv.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    /**
     Creates new `UITextFieldWithLabel` with given textField, Label and spacing
     - Parameter textField: given TextField to layout inside this view
     - Parameter label: given Label to layout inside this view
     - Parameter spacing: space in points between label and TextField
    */
    init(view: UIView, label: UILabel, spacing: CGFloat) {
        self.view = view
        self.label = label
        self.spacing = spacing
        super.init(frame: .zero)
        layout()
    }
    
    /// Creates simple `UITextFieldWithLabel` with default Label and TextField
    init() {
        self.view = UITextField()
        self.label = UILabel()
        self.spacing = 1
        super.init(frame: .zero)
        layout()
    }
    
    /// Forbidden to create from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getView() -> UIView {
        return view
    }
    
    func getLabel() -> UILabel {
        return label
    }
    
}

/// TextField with label above it
class UITextFieldWithLabel: UIView {
    /// Actual TextField
    private var textField: UITextField
    /// Actual Label
    private var label: UILabel
    /// Spacing between Label and TextField
    private var spacing: CGFloat
    
    /// Layouts views inside `UITextFieldWithLabel`
    private func layout() {
        let sv = UIStackView(arrangedSubviews: [label, textField])
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.spacing = spacing
        
        self.addSubview(sv)
        sv.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    /**
     Creates new `UITextFieldWithLabel` with given textField, Label and spacing
     - Parameter textField: given TextField to layout inside this view
     - Parameter label: given Label to layout inside this view
     - Parameter spacing: space in points between label and TextField
    */
    init(textField: UITextField, label: UILabel, spacing: CGFloat) {
        self.textField = textField
        self.label = label
        self.spacing = spacing
        super.init(frame: .zero)
        layout()
    }
    
    /// Creates simple `UITextFieldWithLabel` with default Label and TextField
    init() {
        self.textField = UITextField()
        self.label = UILabel()
        self.spacing = 1
        super.init(frame: .zero)
        layout()
    }
    
    /// Forbidden to create from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTextField() -> UITextField {
        return textField
    }
    
    func getLabel() -> UILabel {
        return label
    }
    
}
