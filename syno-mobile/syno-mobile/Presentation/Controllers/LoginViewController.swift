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
    
    private var presAssembly: IPresentationAssembly

    init(presAssembly: IPresentationAssembly, loginModel: ILoginModel, registrationViewController: UIViewController) {
        self.presAssembly = presAssembly
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
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window!.rootViewController = presAssembly.mainTabBarController()
    }

    func onFailedLogin() {
        Logger.log(#function)
        
        self.processingSaveView.dismissSavingProcessView()
        
        self.present(UIAlertController.okAlertController(title: "Login Failed"), animated: true, completion: nil)

        self.layouter.submitButton().isEnabled = true
        self.layouter.passwordTextField().text = ""
    }

    @objc func skipRegistration() {
        self.loginModel.skippedRegistration()
    }
    
    override func viewDidLoad() {
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        layouter.submitButton().addTarget(self, action: #selector(submitLoginCredentials), for: .touchUpInside)
        layouter.alternateAuthButton().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registrationLabelClicked)))
        layouter.skipRegistrationButton().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipRegistration)))
        
        
        
    
        self.view.backgroundColor = .white;
        
        let allScreenStackView = self.layouter.allStackView()
        self.view.addSubview(allScreenStackView)

        allScreenStackView.anchor(top: self.view.topAnchor, left: nil, bottom: self.view.bottomAnchor, right: nil,
                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        allScreenStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        allScreenStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true

        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardObservers()
    }
}


extension LoginViewController {

    
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {

            let loginButton = self.layouter.submitButton()
            
            let focusedViewOrigin = loginButton.superview!.convert(loginButton.frame.origin, to: self.view)
            
            if keyboardHeight > self.view.frame.height - focusedViewOrigin.y {
                self.view.frame.origin.y = -(keyboardHeight - (self.view.frame.height - focusedViewOrigin.y - loginButton.frame.height))
            }
        }
    }
    
    @objc func hideKeyboard(notification: NSNotification) {
        Logger.log("Hide")
        self.view.frame.origin.y = 0
    }
    
    @objc func clearKeyboard() {
        view.endEditing(true)
    }
}
