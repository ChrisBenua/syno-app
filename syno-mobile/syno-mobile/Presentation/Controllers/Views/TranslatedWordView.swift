import Foundation
import UIKit

/// View for displaying translated word
class TranslatedWordView: UIView {
    
    /// background shadow view
    lazy var shadowView: UIView = {
        let view = BaseShadowView()
        view.containerViewBackgroundColor = UIColor(red: 239.0/255, green: 239.0/255, blue: 239.0/255, alpha: 1)
        view.cornerRadius = 12
        view.shadowView.shadowOffset = CGSize(width: 0, height: 2)
        
        return view
    }()
    
    /// TextField for displaying translated word
    lazy var translatedWordLabel: UITextField = {
        let label = UITextField()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .headerMainColor
        label.textAlignment = .center
        label.placeholder = "Переводимое слово"
        
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(shadowView)
        self.shadowView.addSubview(translatedWordLabel)
        
        shadowView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        translatedWordLabel.anchor(top: self.shadowView.topAnchor, left: self.shadowView.leftAnchor, bottom: self.shadowView.bottomAnchor, right: self.shadowView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingBottom: 10, paddingRight: 5, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
