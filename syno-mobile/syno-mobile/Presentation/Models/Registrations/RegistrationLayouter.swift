import Foundation
import UIKit

/// Extension for `ILoginLayouter` protocol with new field
protocol IRegistrationLayouter: ILoginLayouter {
    /// Gets TextField with password confirmation
    func passwordConfirmationTextField() -> UITextField
    
    //func 
}

class RegistrationLayouter: LoginRegistrationLayouter, IRegistrationLayouter {
    /// TextField for entering password confirmation
    private var _passwordConfirmationTextField: UITextField?
    
    /// Stack view with all views
    private var _allStackView: UIStackView?
    
    /// Button for registration
    private var _loginButtonView: UIView?
    
    /// Button for switching to Login
    private var _alternateAuthButton: UIView?
    
    override func alternateAuthButton() -> UIView {
        if let v = _alternateAuthButton {
            return v
        }
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.text = "Вход"
        label.textColor = .white
        label.textAlignment = .center
        
        _alternateAuthButton = label
        return _alternateAuthButton!
    }
    
    override func alternateAuthButtonContainerView() -> UIView {
        if let v = _loginButtonView {
            return v
        }
        
        let view = UIView(); view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self.alternateAuthButton())

        self.alternateAuthButton().anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.alternateAuthButton().centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _loginButtonView = view
        return view
    }
    
    func passwordConfirmationTextField() -> UITextField {
        if let tf = _passwordConfirmationTextField {
            return tf
        }
        
        let tf = CommonUIElements.defaultTextField(cornerRadius: 20, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        tf.placeholder = "Подтвердите Пароль"
        tf.isSecureTextEntry = true
        tf.font = .systemFont(ofSize: 20)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        
        _passwordConfirmationTextField = tf
        return _passwordConfirmationTextField!
    }
    
    override func generateInnerStackView() -> UIStackView {
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        let sepView2 = UIView(); sepView2.translatesAutoresizingMaskIntoConstraints = false
        let sepView3 = UIView(); sepView3.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [emailTextField(), sepView1, passwordTextField(), sepView3, passwordConfirmationTextField(), sepView2, submitButton()])
        sv.axis = .vertical
        sv.distribution = .fill

        emailTextField().heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.19).isActive = true
        passwordTextField().heightAnchor.constraint(equalTo: emailTextField().heightAnchor).isActive = true
        passwordConfirmationTextField().heightAnchor.constraint(equalTo: emailTextField().heightAnchor).isActive = true
        submitButton().heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.19).isActive = true

        sepView1.heightAnchor.constraint(equalTo: sepView2.heightAnchor, multiplier: 2.0 / 3.0).isActive = true
        sepView1.heightAnchor.constraint(equalTo: sepView3.heightAnchor).isActive = true

        return sv
    }
    
    override func allStackView() -> UIStackView {
        if let sv = _allStackView {
            return sv
        }
        
        let topSepView = UIView(); topSepView.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        let imageContainerView = UIView()
        topSepView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        imageContainerView.anchor(top: nil, left: topSepView.leftAnchor, bottom: topSepView.bottomAnchor, right: topSepView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        imageContainerView.heightAnchor.constraint(equalTo: topSepView.heightAnchor, multiplier: 0.5).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: topSepView.widthAnchor, multiplier: 0.6).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0 / 1.7).isActive = true
        
        
        //let bottomSepView = UIView(); bottomSepView.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [topSepView, formBackgroundView])
        sv.axis = .vertical
        sv.distribution = .fill

        topSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.48).isActive = true
        //bottomSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.35).isActive = true
        _allStackView = sv
        return sv
    }
    
    override init() {
        super.init()
        self.submitButton().setAttributedTitle(NSAttributedString(string: "Зарегистрироваться", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]), for: UIKit.UIControl.State.normal)
    }
    
}
