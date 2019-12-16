//
//  RegistrationViewController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 29.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class RegistrationViewController: UIViewController, IRegistrationReactor {
    func startedProcessingRegistration() {
        print("Starter")
        self.layouter.submitButton().isEnabled = false
        self.processingSaveView.showSavingProcessView(sourceView: self)
    }
    
    func failed(error: String) {
        print("Failed: \(error)")
        self.layouter.submitButton().isEnabled = true
        
        self.processingSaveView.dismissSavingProcessView()
        
        self.present(UIAlertController.okAlertController(title: "Registration Failed: \(error)"), animated: true, completion: nil)
    }
    
    func success() {
        print("Success")
        self.layouter.submitButton().isEnabled = true
        
        self.processingSaveView.dismissSavingProcessView()

        let alert = UIAlertController.okAlertController(title: "You registered successfully")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 0.6

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true)
        })
    }
    
    private var layouter: IRegistrationLayouter = RegistrationLayouter()
        
    private var model: IRegistrationModel
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Signing in..")
        
        return view
    }()
    
    @objc func onLoginButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    init(registerModel: IRegistrationModel) {
        self.model = registerModel
        super.init(nibName: nil, bundle: nil)
        self.model.reactor = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        
        layouter.alternateAuthButton().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onLoginButtonClick)))
        
        self.view.backgroundColor = .white;
        
        let allScreenStackView = self.layouter.allStackView()
        self.view.addSubview(allScreenStackView)

        allScreenStackView.anchor(top: self.view.topAnchor, left: nil, bottom: self.view.bottomAnchor, right: nil,
                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        allScreenStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        allScreenStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true

        super.viewDidLoad()
        
        self.layouter.emailTextField().addTarget(self.model.state, action: #selector(self.model.state.emailTFDidChange(sender:)), for: .editingChanged)
        self.layouter.passwordConfirmationTextField().addTarget(self.model.state, action: #selector(self.model.state.passwordConfTFDidChange(sender:)), for: .editingChanged)
        self.layouter.passwordTextField().addTarget(self.model.state, action: #selector(self.model.state.passwordTFDidChange(sender:)), for: .editingChanged)
        self.layouter.submitButton().addTarget(self, action: #selector(onSubmitButtonClick), for: .touchUpInside)
    }
    
    @objc func onSubmitButtonClick() {
        self.model.register()
    }
}


extension RegistrationViewController {
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
        self.view.frame.origin.y = 0
    }
    
    @objc func clearKeyboard() {
        view.endEditing(true)
    }
}
