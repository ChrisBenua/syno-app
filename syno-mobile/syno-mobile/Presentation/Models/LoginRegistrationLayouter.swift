//
//  LoginRegistrationLayouter.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 29.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ILoginLayouter {
    func passwordTextField() -> UITextField
    
    func emailTextField() -> UITextField
    
    func submitButton() -> UIButton
    
    func alternateAuthButton() -> UIView
    
    func allStackView() -> UIStackView
}



class LoginRegistrationLayouter: ILoginLayouter {
    
    private var _passwordTextField: UITextField?
    
    private var _emailTextField: UITextField?
    
    private var _submitButton: UIButton?
    
    private var _allStackView: UIStackView?
    
    private var _alternateAuthButtonContainerView: UIView?
    
    private var _alternateAuthButton: UIView?
    
    func passwordTextField() -> UITextField {
        if let passwordTf = _passwordTextField {
            return passwordTf
        }
        
        let tf = CommonUIElements.defaultTextField(cornerRadius: 20, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
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
        
        let tf = CommonUIElements.defaultTextField(cornerRadius: 20, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
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
        
        let button = CommonUIElements.defaultSubmitButton(text: "Войти", cornerRadius: 25)
        button.setAttributedTitle(NSAttributedString(string: "Войти", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]), for: UIKit.UIControl.State.normal)

        //button.addTarget(self, action: #selector(submitLoginCredentials), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        _submitButton = button
        return _submitButton!
    }

    func generateInnerStackView() -> UIStackView {
        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
        let sepView2 = UIView(); sepView2.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [emailTextField(), sepView1, passwordTextField(), sepView2, submitButton()])
        sv.axis = .vertical
        sv.distribution = .fill

        emailTextField().heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.26).isActive = true
        passwordTextField().heightAnchor.constraint(equalTo: emailTextField().heightAnchor).isActive = true
        submitButton().heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.26).isActive = true

        sepView1.heightAnchor.constraint(equalTo: sepView2.heightAnchor, multiplier: 2.0 / 3.0).isActive = true

        return sv
    }

    lazy var synoTitleAboveEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40)
        label.textColor = .white
        label.text = "Syno"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
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
        
        let view = UIView(); view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self.alternateAuthButton())

        self.alternateAuthButton().anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.alternateAuthButton().centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _alternateAuthButtonContainerView = view
        return view
    }

    private lazy var allLoginStackView: UIStackView = {
        let synoTitleLoginSepView = UIView(); synoTitleLoginSepView.translatesAutoresizingMaskIntoConstraints = false
        let loginButtonRegistrationSepView = UIView(); loginButtonRegistrationSepView.translatesAutoresizingMaskIntoConstraints = false
        let bottomSepView = UIView(); bottomSepView.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [synoTitleAboveEmailLabel, synoTitleLoginSepView, generateInnerStackView(),
                                                loginButtonRegistrationSepView, self.alternateAuthButtonContainerView(), bottomSepView])

        sv.axis = .vertical
        sv.distribution = .fill

        synoTitleAboveEmailLabel.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
        synoTitleLoginSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.035).isActive = true
        loginButtonRegistrationSepView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        alternateAuthButtonContainerView().heightAnchor.constraint(equalToConstant: 40).isActive = true
        bottomSepView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        return sv
    }()

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
        //let bottomSepView = UIView(); bottomSepView.translatesAutoresizingMaskIntoConstraints = false
        let sv = UIStackView(arrangedSubviews: [topSepView, formBackgroundView])
        sv.axis = .vertical
        sv.distribution = .fill

        topSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.55).isActive = true
        //bottomSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.35).isActive = true
        _allStackView = sv
        return sv
    }
    
}
