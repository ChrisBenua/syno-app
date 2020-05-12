import Foundation
import UIKit

///TextField with needed paddings from top left bottom right
class UITextFieldWithInsets: UITextField {
    
    /// Actual padding from bounds
    private var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

    /// Draws text in rect with insets
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }
    
    /// Overriding `editingRect` for correct hit box
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }
    
    /// Overriding `intrinsicContentSize` property for AutoLayout
    override var intrinsicContentSize: CGSize {
        let superSz = super.intrinsicContentSize
        return CGSize(width: superSz.width + insets.left + insets.right, height: superSz.height + insets.top + insets.bottom)
    }
    
    /// Creates new `UITextFieldWithInsets` with given insets
    init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    /// Create a new `UITextFieldWithInsets` instance from Storyboard with default insets
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
