import Foundation
import UIKit

/// UITextView and Label above it
class UITextViewWithLabel: UIView {
    /// Actual textView
    private var textView: UITextView
    /// Actial Label
    private var label: UILabel
    /// Spacing between Label and TextView
    private var spacing: CGFloat
    
    /// Layouts this view
    private func layout() {
        let sv = UIStackView(arrangedSubviews: [label, textView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = spacing
        
        self.addSubview(sv)
        sv.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    /**
        Create new `UITextViewWithLabel` with given TextView, Label and spacing
     - Parameter textView: Given TextView
     - Parameter label: Given Label
     - Parameter spacing: Spacing between TextView and Label
     */
    init(textView: UITextView, label: UILabel, spacing: CGFloat) {
        self.textView = textView
        self.label = label
        self.spacing = spacing
        super.init(frame: .zero)
        layout()
    }
    
    /**
     Create new `UITextViewWithLabel` with default Label and TextView
     */
    init() {
        self.textView = UITextView()
        self.label = UILabel()
        self.spacing = 1
        super.init(frame: .zero)
        layout()
    }
    
    /// Forbidden to create from Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Styles TextView
     - Parameter styleFunc: callback for styling TextView
     */
    func styleTextView(styleFunc: (UITextView) -> ()) {
        styleFunc(textView)
    }
    
    /**
    Styles Label
    - Parameter styleFunc: callback for styling Label
    */
    func styleLabel(styleFunc: (UILabel) -> ()) {
        styleFunc(label);
    }
    
    func getTextView() -> UITextView {
        return textView
    }
    
    func getLabel() -> UILabel {
        return label
    }
    
}
