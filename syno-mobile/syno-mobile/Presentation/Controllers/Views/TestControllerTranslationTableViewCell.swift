//
//  TestControllerTranslationTableViewCell.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.01.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ITestControllerTranslationCellConfiguration {
    var translation: String? { get set }
}

class TestControllerTranslationCellConfiguration: ITestControllerTranslationCellConfiguration {
    var translation: String?
    
    init(translation: String?) {
        self.translation = translation
    }
}

protocol IConfigurableTestControllerTranslationCell {
    func setup(config: ITestControllerTranslationCellConfiguration)
}

protocol ITestControllerTranslationCellDelegate: class {
    func textDidChange(sender: UITableViewCell, text: String?)
}

class TestControllerTranslationTableViewCell: UITableViewCell, IConfigurableTestControllerTranslationCell, UITextFieldDelegate {
    static let cellId = "TestControllerTranslationTableViewCellId"
    
    weak var delegate: ITestControllerTranslationCellDelegate?
    
    weak var editingDelegate: ITextFieldTestControllerEditingDelegate?
        
    var translation: String?
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingDelegate?.beginEditingInCell(cell: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingDelegate?.endEditingInCell(cell: self)
    }
    
    func updateUI() {
        self.translationTextField.text = translation
    }
    
    func setup(config: ITestControllerTranslationCellConfiguration) {
        self.translation = config.translation
        
        updateUI()
    }
    
    lazy var translationTextField: UITextField = {
        let tf = UITextFieldWithInsets(insets: UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
        tf.backgroundColor = .white
        tf.font = .systemFont(ofSize: 22, weight: .light)
        tf.addTarget(self, action: #selector(onTranslationTextChanged(_:)), for: .editingChanged)
        tf.clipsToBounds = true
        
        tf.layer.cornerRadius = 7
        
        return tf
    }()
    
    @objc func onTranslationTextChanged(_ textField: UITextField) {
        delegate?.textDidChange(sender: self, text: textField.text)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.contentView.addSubview(translationTextField)
        
        translationTextField.delegate = self
        
        translationTextField.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
