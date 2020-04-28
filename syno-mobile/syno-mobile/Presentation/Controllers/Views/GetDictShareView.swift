import Foundation
import UIKit

/// Protocol for `GetDictShareView` event handling
protocol IGetDictShareDelegate: class {
    func didSubmitText(text: String)
}

/// View for receiving shared dict
class GetDictShareView: UIView {
    /// Event handler
    weak var delegate: IGetDictShareDelegate?
    
    /// View for share UUID input
    lazy var shareUUIDInputView: UITextViewWithLabel = {
        let textView = UITextView()
        textView.clipsToBounds = true
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 10
        
        textView.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        
        textView.font = .systemFont(ofSize: 19)
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Код:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        return UITextViewWithLabel(textView: textView, label: label, spacing: 3)
    }()
    
    /// Button for submission
    lazy var submitButton: UIButton = {
        let button = CommonUIElements.defaultSubmitButton(text: "Загрузить", cornerRadius: 15, textColor: .white)
        
        button.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        
        return button
    }()
    
    /// Submit button event listener
    @objc func onSubmit() {
        self.delegate?.didSubmitText(text: self.shareUUIDInputView.getTextView().text)
    }
    
    /// Wrapper Stack view with `shareUUIDInputView` and `submitButton`
    lazy var stackView: UIStackView = {
        let sepView = UIView()
        let sv = UIStackView(arrangedSubviews: [self.shareUUIDInputView, sepView, self.submitButton])
        sv.axis = .vertical
        sv.distribution = .fill
        
        sepView.heightAnchor.constraint(equalTo: self.submitButton.heightAnchor, multiplier: 1).isActive = true
        self.submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.shareUUIDInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
        
        return sv
    }()
    
    /// Main view
    lazy var baseShadowView: BaseShadowView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 22, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(baseShadowView)
        self.baseShadowView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
