//
//  AccountConfirmation.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 25.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class AccountConfirmationController: UIViewController {
    
    var model: IAccountConfirmationModel
    
    weak var controllerToPop: UIViewController?
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Подтверждаем")
        
        return view
    }()
    
    lazy var digitTextFields: [UITextField] = {
        let textFields = (0..<6).map { (_) -> UITextField in
            let textField = BackspaceUITextField()
            textField.backspaceDelegate = self
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.textAlignment = .center
            textField.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
            textField.layer.cornerRadius = 10
            textField.layer.borderWidth = 0.5
            textField.layer.borderColor = UIColor(red: 196.0/255, green: 196.0/255, blue: 196.0/255, alpha: 1).cgColor
            textField.clipsToBounds = true

            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(handleTextFieldChanges(sender:)), for: .editingChanged)
            textField.heightAnchor.constraint(equalTo: textField.widthAnchor).isActive = true
            
            return textField
        }
        
        return textFields
    }()
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "Введите код подтверждения"
        label.font = .systemFont(ofSize: 22)
        
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = CommonUIElements.defaultSubmitButton(text: "Подтвердить", backgroundColor: UIColor.init(red: 73.0/255, green: 116.0/255, blue: 171.0/255, alpha: 0.65), type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Подтвердить", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
        
        button.addTarget(self, action: #selector(confirmationButtonOnClick), for: .touchUpInside)
        
        return button
    }()
    
    lazy var digitTextFieldsStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: self.digitTextFields)
        //sv.spacing = 10
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        
        return sv
    }()
    
    func layout() {
        let sepView1 = UIView(); let sepView2 = UIView(); let botView = UIView()
        let sv = UIStackView(arrangedSubviews: [titleView, sepView1, digitTextFieldsStackView, sepView2, confirmButton, botView])
        self.view.addSubview(sv)
        sepView1.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08).isActive = true
        sepView2.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12).isActive = true
        sv.axis = .vertical
        sv.distribution = .fill
        
        sv.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        sv.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        sv.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8).isActive = true
        
        for tf in digitTextFields {
            tf.widthAnchor.constraint(equalTo: sv.widthAnchor, multiplier: 0.14).isActive = true
        }
    }
    
    @objc func confirmationButtonOnClick() {
        self.processingSaveView.showSavingProcessView(sourceView: self)
        self.model.confirm(code: self.digitTextFields.map({ (el) -> String in
            return el.text!
        }).reduce("", { (res, str) -> String in
            return res + str
        }))
    }
    
    @objc func handleTextFieldChanges(sender: UITextField) {
        Logger.log("handler")
        let text = sender.text!
        if (text.count > 1) {
            sender.text = text.substring(from: text.index(after: text.startIndex))
        }
        
        let tfIndex = self.digitTextFields.firstIndex(of: sender)!
        if text.count == 0 && tfIndex > 0 {
            self.digitTextFields[tfIndex - 1].becomeFirstResponder()
        } else if text.count >= 1 && tfIndex < self.digitTextFields.count - 1 {
            self.digitTextFields[tfIndex + 1].becomeFirstResponder()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        layout()
    }
    
    init(model: IAccountConfirmationModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)

        self.model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountConfirmationController: IBackspaceUITextFieldDelegate {
    func onBackspace(sender: UITextField) {
        if (sender.text?.count ?? 0) == 0, let tfIndex = self.digitTextFields.firstIndex(of: sender) {
            if tfIndex > 0 {
                self.digitTextFields[tfIndex - 1].becomeFirstResponder()
                self.digitTextFields[tfIndex - 1].text = ""
            }
        }
    }
}

extension AccountConfirmationController: IAccountConfirmationModelDelegate {
    func onSuccess() {
        self.processingSaveView.dismissSavingProcessView()
        
        let alert = UIAlertController.okAlertController(title: "Успех", message: "Аккаунт подтвержден!")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: {
                    self.controllerToPop?.dismiss(animated: true, completion: nil)
                })
            })
        })
    }
    
    func onFailure(message: String) {
        self.processingSaveView.dismissSavingProcessView()
        
        let alert = UIAlertController.okAlertController(title: "Ошибка", message: message)
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
}

