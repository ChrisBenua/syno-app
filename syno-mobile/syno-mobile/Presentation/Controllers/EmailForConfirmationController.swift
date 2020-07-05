//
//  EmailForConfirmationController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 27.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class EmailForConfirmationController: UIViewController {
    
    private var model: IEmailConfirmationModel
    
    private var presentationAssembly: IPresentationAssembly
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Отправка..")
        
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.tintColor = .headerMainColor
        
        button.addTarget(self, action: #selector(onCancelButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите email, на который вы уже регистрировали аккаунт:"
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextFieldWithInsets(insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        tf.textAlignment = .center
        tf.placeholder = "Ваш email"
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
        tf.backgroundColor = .textFieldsMainColor
        tf.autocapitalizationType = .none
        
        tf.font = .systemFont(ofSize: 18)
        
        return tf
    }()
    
    lazy var submitButton: UIButton = {
         let button = CommonUIElements.defaultSubmitButton(text: "Подтвердить", backgroundColor: UIColor.init(red: 73.0/255, green: 116.0/255, blue: 171.0/255, alpha: 0.65), type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Подтвердить", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
               
        button.addTarget(self, action: #selector(confirmEmailButton), for: .touchUpInside)
               
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let sepView2 = UIView(); let sepView = UIView()
        let sv = UIStackView(arrangedSubviews: [self.headingLabel, sepView, self.emailTextField, sepView2, self.submitButton])
        sv.axis = .vertical
        sv.distribution = .fill
        
        sepView2.heightAnchor.constraint(equalTo: self.emailTextField.heightAnchor, multiplier: 1).isActive = true
        sepView.heightAnchor.constraint(equalTo: self.emailTextField.heightAnchor, multiplier: 0.8).isActive = true
        
        return sv
    }()
    
    @objc func confirmEmailButton() {
        processingSaveView.showSavingProcessView(sourceView: self)
        self.model.resendEmailConfirmation(email: self.emailTextField.text!)
    }
    
    @objc func onCancelButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(cancelButton)
        self.view.addSubview(self.stackView)
        
        cancelButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        self.stackView.anchor(top: cancelButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.backgroundColor = .white
    }
    
    init(model: IEmailConfirmationModel, presentationAssembly: IPresentationAssembly) {
        self.model = model
        self.presentationAssembly = presentationAssembly
        super.init(nibName: nil, bundle: nil)
        self.model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmailForConfirmationController: IEmailConfirmationModelDelegate {
    func onSuccess() {
        processingSaveView.dismissSavingProcessView()
        let alert = UIAlertController.okAlertController(title: "Успех", message: "Письмо отпралвено")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: {
                var controller = self.presentationAssembly.accountConfirmationController()
                controller.controllerToPop = self
                self.present(controller, animated: true)
            })
        })
    }
    
    func onError(error: String) {
        processingSaveView.dismissSavingProcessView()
        let alert = UIAlertController.okAlertController(title: "Ошибка", message: error)
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: {
            })
        })
    }
}

