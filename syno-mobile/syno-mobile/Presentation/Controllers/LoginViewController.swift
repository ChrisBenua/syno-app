//
//  ViewController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 22.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import UIKit
import AVFoundation

protocol ILoginReactor {
    func onStartedProcessingLogin()

    func onSuccessfulLogin(email: String)

    func onFailedLogin()
}

class LoginViewController: UIViewController, ILoginReactor {

    private var loginModel: ILoginModel
    
    private var layouter: ILoginLayouter = LoginRegistrationLayouter()
    
    private var registrationViewController: UIViewController

    init(loginModel: ILoginModel, registrationViewController: UIViewController) {
        self.loginModel = loginModel
        self.registrationViewController = registrationViewController
        super.init(nibName: nil, bundle: nil)
        self.loginModel.controller = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Logging in..")
        
        return view
    }()
    
//    lazy var passwordTextField: UITextField = {
//        let tf = CommonUIElements.defaultTextField(cornerRadius: 20, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
//        tf.placeholder = "Пароль"
//        tf.isSecureTextEntry = true
//        tf.font = .systemFont(ofSize: 20)
//        tf.translatesAutoresizingMaskIntoConstraints = false
//        tf.autocapitalizationType = .none
//        return tf
//    }()
//
//    lazy var emailTextField: UITextField = {
//        let tf = CommonUIElements.defaultTextField(cornerRadius: 20, edgeInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
//        tf.placeholder = "Email"
//        tf.font = .systemFont(ofSize: 20)
//        tf.translatesAutoresizingMaskIntoConstraints = false
//        tf.autocapitalizationType = .none
//        return tf
//    }()
//
//    lazy var loginButton: UIButton = {
//        let button = CommonUIElements.defaultSubmitButton(text: "Войти", cornerRadius: 25)
//        button.setAttributedTitle(NSAttributedString(string: "Войти", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]), for: UIKit.UIControl.State.normal)
//
//        button.addTarget(self, action: #selector(submitLoginCredentials), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    func generateInnerStackView() -> UIStackView {
//        let sepView1 = UIView(); sepView1.translatesAutoresizingMaskIntoConstraints = false
//        let sepView2 = UIView(); sepView2.translatesAutoresizingMaskIntoConstraints = false
//        let sv = UIStackView(arrangedSubviews: [emailTextField, sepView1, passwordTextField, sepView2, loginButton])
//        sv.axis = .vertical
//        sv.distribution = .fill
//
//        emailTextField.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.26).isActive = true
//        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
//        loginButton.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.26).isActive = true
//
//        sepView1.heightAnchor.constraint(equalTo: sepView2.heightAnchor, multiplier: 2.0 / 3.0).isActive = true
//
//        return sv
//    }
//
//    lazy var synoTitleAboveEmailLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 40)
//        label.textColor = .white
//        label.text = "Syno"
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        return label
//    }()
//
//    lazy var registrationButton: UILabel = {
//        let label = UILabel()
//        label.isUserInteractionEnabled = true
//        label.text = "Регистрация"
//        label.textColor = .white
//        label.textAlignment = .center
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(registrationLabelClicked))
//
//        label.addGestureRecognizer(tapGesture)
//
//        return label
//    }()
//
//    lazy var regustrationButtonContainerView: UIView = {
//        let view = UIView(); view.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(self.registrationButton)
//
//        self.registrationButton.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        self.registrationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//
//        return view
//    }()
//
//    lazy var allLoginStackView: UIStackView = {
//        let synoTitleLoginSepView = UIView(); synoTitleLoginSepView.translatesAutoresizingMaskIntoConstraints = false
//        let loginButtonRegistrationSepView = UIView(); loginButtonRegistrationSepView.translatesAutoresizingMaskIntoConstraints = false
//        let bottomSepView = UIView(); bottomSepView.translatesAutoresizingMaskIntoConstraints = false
//        let sv = UIStackView(arrangedSubviews: [synoTitleAboveEmailLabel, synoTitleLoginSepView, generateInnerStackView(),
//                                                loginButtonRegistrationSepView, self.regustrationButtonContainerView, bottomSepView])
//
//        sv.axis = .vertical
//        sv.distribution = .fill
//
//        synoTitleAboveEmailLabel.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.15).isActive = true
//        synoTitleLoginSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.035).isActive = true
//        loginButtonRegistrationSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.06).isActive = true
//        regustrationButtonContainerView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.09).isActive = true
//        bottomSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.11).isActive = true
//
//        return sv
//    }()
//
//    lazy var formBackgroundView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(red: 36.0/255, green: 48.0/255, blue: 63.0/255, alpha: 1)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.masksToBounds = true
//        view.layer.cornerRadius = 25
//        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//
//        view.addSubview(allLoginStackView)
//        allLoginStackView.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor,
//                right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        allLoginStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        allLoginStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.72).isActive = true
//        return view
//    }()
//
//    lazy var allScreenStackView: UIStackView = {
//       let topSepView = UIView(); topSepView.translatesAutoresizingMaskIntoConstraints = false
//        //let bottomSepView = UIView(); bottomSepView.translatesAutoresizingMaskIntoConstraints = false
//        let sv = UIStackView(arrangedSubviews: [topSepView, formBackgroundView])
//        sv.axis = .vertical
//        sv.distribution = .fill
//
//        topSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.55).isActive = true
//        //bottomSepView.heightAnchor.constraint(equalTo: sv.heightAnchor, multiplier: 0.35).isActive = true
//
//        return sv
//    }()

    @objc func registrationLabelClicked() {
        print("OBAMA")
        self.present(registrationViewController, animated: true, completion: nil)
    }

    @objc func submitLoginCredentials() {
        print("Submit")
        
        //AVSpeechSynthesizer().speak(AVSpeechUtterance(string: emailTextField.text!))
        //TODO
        self.loginModel.login(loginState: LoginState(email: layouter.emailTextField().text ?? "", password: layouter.passwordTextField().text ?? ""))
    }

    func onStartedProcessingLogin() {
        Logger.log(#function)
        self.layouter.submitButton().isEnabled = false
        
        self.processingSaveView.showSavingProcessView(sourceView: self)
    }

    func onSuccessfulLogin(email: String) {
        Logger.log(#function)
        self.layouter.submitButton().isEnabled = true
        
        self.processingSaveView.dismissSavingProcessView()

        let alert = UIAlertController.okAlertController(title: "Welcome, \(email)!")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 0.6

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true)
        })
        
        //TODO
        //(self.loginModel as! LoginModel).kek()
    }

    func onFailedLogin() {
        Logger.log(#function)
        
        self.processingSaveView.dismissSavingProcessView()
        
        self.present(UIAlertController.okAlertController(title: "Login Failed"), animated: true, completion: nil)

        self.layouter.submitButton().isEnabled = true
        self.layouter.passwordTextField().text = ""
    }

    
    override func viewDidLoad() {
        layouter.submitButton().addTarget(self, action: #selector(submitLoginCredentials), for: .touchUpInside)
        layouter.alternateAuthButton().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registrationLabelClicked)))
        
        
        
        
        self.view.backgroundColor = .white;
        
        let allScreenStackView = self.layouter.allStackView()
        self.view.addSubview(allScreenStackView)

        allScreenStackView.anchor(top: self.view.topAnchor, left: nil, bottom: self.view.bottomAnchor, right: nil,
                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        allScreenStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        allScreenStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true

        super.viewDidLoad()
    }
}


