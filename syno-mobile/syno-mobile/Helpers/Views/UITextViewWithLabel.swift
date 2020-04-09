import Foundation
import UIKit

class UITextViewWithLabel: UIView {
    private var textView: UITextView
    private var label: UILabel
    private var spacing: CGFloat
    
    private func layout() {
        let sv = UIStackView(arrangedSubviews: [label, textView])
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.spacing = spacing
        
        self.addSubview(sv)
        sv.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    init(textView: UITextView, label: UILabel, spacing: CGFloat) {
        self.textView = textView
        self.label = label
        self.spacing = spacing
        super.init(frame: .zero)
        layout()
    }
    
    init() {
        self.textView = UITextView()
        self.label = UILabel()
        self.spacing = 1
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleTextField(styleFunc: (UITextView) -> ()) {
        styleFunc(textView)
    }
    
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
