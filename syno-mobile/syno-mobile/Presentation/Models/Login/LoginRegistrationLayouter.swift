import Foundation
import UIKit

/// Protocol for helper class with layout logic
protocol ILoginLayouter {
    /// Gets TextField for password
    func passwordTextField() -> UITextField
    
    /// Gets TextField for email
    func emailTextField() -> UITextField
    
    /// Gets submit button
    func submitButton() -> UIButton
    
    /// Gets registration button
    func alternateAuthButton() -> UIView
    
    /// Gets stack view with all views
    func allStackView() -> UIStackView
    
    /// Gets skip registration button
    func skipRegistrationButton() -> UIView
    
    func resendConfirmationView() -> UIView
}


class LoginRegistrationLayouter: ILoginLayouter {
    /// TextField for entering password
    private var _passwordTextField: UITextField?
    
    /// TextField for entering email
    private var _emailTextField: UITextField?
    
    /// Button for submitiing credentials
    private var _submitButton: UIButton?
    
    /// stack view with all views
    private var _allStackView: UIStackView?
    
    /// Wrapper view for Registration button
    private var _alternateAuthButtonContainerView: UIView?
    
    /// Registration Button
    private var _alternateAuthButton: UIView?
    
    /// Skip registration button
    private var _skipRegistrationButton: UIView?
    
    private var _questionView: UIView?
    
    private var _resendConfirmationView: UIView?
    
    private var _widthConstraint: NSLayoutConstraint?
    
    func resendConfirmationView() -> UIView {
        if let resendConfirmation = _resendConfirmationView {
            return resendConfirmation
        }
        
        let view = UILabel()
        view.text = "Выслать код подтверждения повторно"
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
        view.textColor = UIColor(red: 8 / 255.0, green: 40 / 255.0, blue: 12 * 8 / 255.0, alpha: 1)
        
        _resendConfirmationView = view
        
        return view
    }
    
    func questionView() -> UIView {
        if let view = _questionView {
            return view
        }
        let view = UIView(); view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
    
        let questionLabel = UILabelWithInsets(padding: UIEdgeInsets(top: 8, left: 8, bottom: 7, right: 10))
        questionLabel.textColor = .darkGray
        questionLabel.isUserInteractionEnabled = true
        questionLabel.text = "?"
        questionLabel.font = .systemFont(ofSize: 32)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleQuestionTap))
        
        view.addSubview(questionLabel)
        questionLabel.addGestureRecognizer(tapGR)
        view.addSubview(resendConfirmationView())
        
        questionLabel.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 7, width: 0, height: 0)
        
        resendConfirmationView().anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: questionLabel.leftAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        //resendConfirmationView().isHidden = true
        
        _widthConstraint = resendConfirmationView().widthAnchor.constraint(equalToConstant: 0)
        _widthConstraint?.isActive = true
        
        _questionView = view
        
        return view
    }
    
    @objc func handleQuestionTap() {
        print("TAP")
        _widthConstraint?.isActive.toggle()
        //self.resendConfirmationView().isHidden.toggle()
        
        UIView.animate(withDuration: 0.5) {
            self._allStackView!.layoutIfNeeded()
        }
    }
    
    func passwordTextField() -> UITextField {
        if let passwordTf = _passwordTextField {
            return passwordTf
        }
        
        let tf = CommonUIElements.defaultTextField(cornerRadius: 18, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        tf.placeholder = "Пароль"
        tf.isSecureTextEntry = true
        tf.font = .systemFont(ofSize: 20)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        
        _passwordTextField = tf
        return _passwordTextField!
    }

    func emailTextField() -> UITextField {
        if let emailTf = _emailTextField {
            return emailTf
        }
        
        let tf = CommonUIElements.defaultTextField(cornerRadius: 18, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        tf.placeholder = "Email"
        tf.font = .systemFont(ofSize: 20)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        
        _emailTextField = tf
        return _emailTextField!
    }

    func submitButton() -> UIButton {
        
        if let but = _submitButton {
            return but
        }
        
        let button = CommonUIElements.defaultSubmitButton(text: "Войти", cornerRadius: 18)
        button.setAttributedTitle(NSAttributedString(string: "Войти", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]), for: UIKit.UIControl.State.normal)

        button.translatesAutoresizingMaskIntoConstraints = false
        
        _submitButton = button
        return _submitButton!
    }

    /// Generates  stack view with `emailTextField`, `passwordTextField` and `submitButton` inside
    func generateInnerStackView() -> UIStackView {
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        let sepView2 = UIView(); sepView2.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [emailTextField(), sepView1, passwordTextField(), sepView2, submitButton()])
        sv.axis = .vertical
        sv.distribution = .fill

        emailTextField().heightAnchor.constraint(greaterThanOrEqualTo: sv.heightAnchor, multiplier: 0.26).isActive = true
        passwordTextField().heightAnchor.constraint(equalTo: emailTextField().heightAnchor).isActive = true
        submitButton().heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.26).isActive = true

        sepView1.heightAnchor.constraint(equalTo: sepView2.heightAnchor, multiplier: 2.0 / 3.0).isActive = true

        return sv
    }
    
    func alternateAuthButton() -> UIView {
        if let v = _alternateAuthButton {
            return v
        }
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.text = "Регистрация"
        label.textColor = .white
        label.textAlignment = .center
        
        _alternateAuthButton = label
        return _alternateAuthButton!
    }

    func alternateAuthButtonContainerView() -> UIView {
        if let but = _alternateAuthButtonContainerView {
            return but
        }
        
        let containerView = UIStackView(arrangedSubviews: [alternateAuthButton(), skipRegistrationButton()])
        containerView.axis = .horizontal
        containerView.distribution = .fillEqually
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        _alternateAuthButtonContainerView = containerView
        return containerView
    }

    /// Stack view with logo, `generateInnerStackView`, `alternateAuthButtonContainerView`
    private lazy var allLoginStackView: UIStackView = {
        let synoTitleLoginSepView = UIView(); synoTitleLoginSepView.translatesAutoresizingMaskIntoConstraints = false
        let loginButtonRegistrationSepView = UIView(); loginButtonRegistrationSepView.translatesAutoresizingMaskIntoConstraints = false
        let bottomSepView = UIView(); bottomSepView.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [synoTitleLoginSepView, generateInnerStackView(),
                                                loginButtonRegistrationSepView, self.alternateAuthButtonContainerView(), bottomSepView])

        sv.axis = .vertical
        sv.distribution = .fill

        //synoTitleAboveEmailLabel.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
        synoTitleLoginSepView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginButtonRegistrationSepView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        alternateAuthButtonContainerView().heightAnchor.constraint(equalToConstant: 40).isActive = true
        bottomSepView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        return sv
    }()

    /// Form's background view
    lazy var formBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 36.0/255, green: 48.0/255, blue: 63.0/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        view.addSubview(allLoginStackView)
        allLoginStackView.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor,
                right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        allLoginStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        allLoginStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.72).isActive = true
        return view
    }()

    func allStackView() -> UIStackView {
        if let sv = _allStackView {
            return sv
        }
        
        let topSepView = UIView(); topSepView.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        let imageContainerView = UIView()
        topSepView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        imageContainerView.anchor(top: nil, left: topSepView.leftAnchor, bottom: topSepView.bottomAnchor, right: topSepView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        imageContainerView.heightAnchor.constraint(equalTo: topSepView.heightAnchor, multiplier: 0.4).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: topSepView.widthAnchor, multiplier: 0.6).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0 / 1.7).isActive = true

        let sv = UIStackView(arrangedSubviews: [topSepView, formBackgroundView])
        sv.axis = .vertical
        sv.distribution = .fill

        topSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.6).isActive = true

        _allStackView = sv
        
        sv.addSubview(questionView())
        
        questionView().anchor(top: _allStackView?.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: _allStackView?.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        questionView().widthAnchor.constraint(lessThanOrEqualTo: _allStackView!.widthAnchor, multiplier: 1, constant: -40).isActive = true
        
        return sv
    }
    
    func skipRegistrationButton() -> UIView {
        if let button = _skipRegistrationButton {
            return button
        }
        
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.text = "Пропустить"
        label.textColor = .white
        label.textAlignment = .center
        
        _skipRegistrationButton = label
        return _skipRegistrationButton!
    }
}
