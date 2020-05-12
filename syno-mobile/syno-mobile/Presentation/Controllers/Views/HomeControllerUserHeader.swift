import Foundation
import UIKit

/// Protocol for `HomeControllerUserHeader` event handling
protocol IHomeControllerUserHeaderDelegate: class {
    func onShowLogin()
}

class HomeControllerUserHeader: UIView {
    /// Event handler
    weak var delegate: IHomeControllerUserHeaderDelegate?
    
    /// Label for displaying user email
    lazy var userEmailLabel: UILabel = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 10))
        label.font = .systemFont(ofSize: 19)
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.textAlignment = .left
        label.backgroundColor = .white
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onEmailTitlePressed)))
        
        return label
    }()
    
    /// Label for displaying title above `userEmailLabel`
    lazy var titleLabel: UILabel = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7))
        label.textColor = .headerMainColor
        label.backgroundColor = .clear
        label.text = "Войти в аккаунт"
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onEmailTitlePressed)))
        
        return label
    }()
    
    /// `titleLabel` click listener
    @objc func onEmailTitlePressed() {
        delegate?.onShowLogin()
    }
    
    /// User icon imageView
    lazy var imageView: UIImageView = {
        let imView = UIImageView(image: #imageLiteral(resourceName: "AVATAR"))
        imView.heightAnchor.constraint(equalTo: imView.widthAnchor, multiplier: 1).isActive = true
        imView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return imView
    }()
    
    /// Main-view with all subviews
    lazy var stackView: UIView = {
        let sv = UIStackView(arrangedSubviews: [self.titleLabel, self.userEmailLabel])
        sv.axis = .vertical
        sv.spacing = 5
        
        let view = UIView()
        view.addSubview(self.imageView)
        view.addSubview(sv)
        
        self.imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25, constant: -10).isActive = true
        
        self.imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.anchor(top: view.topAnchor, left: self.imageView.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
        
        return view
    }()
    
    /**
     Creates new `HomeControllerUserHeader` with given email
     - Parameter email: last logged in user's email
     */
    init(email: String) {
        super.init(frame: .zero)
        self.userEmailLabel.text = "Email: " + email
        self.addSubview(stackView)
        stackView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
