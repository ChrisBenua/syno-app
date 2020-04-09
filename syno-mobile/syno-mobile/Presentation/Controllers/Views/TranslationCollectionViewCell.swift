//
//  TranslationCollectionViewCell.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol ITranslationCellConfiguration {
    var translation: String? { get set }
    var transcription: String? { get set }
    var comment: String? { get set }
    var sample: String? { get set }
}

class TranslationCellConfiguration: ITranslationCellConfiguration {
    var translation: String?
    
    var transcription: String?
    
    var comment: String?
    
    var sample: String?
    
    init(translation: String?, transcription: String?, comment: String?, sample: String?) {
        self.translation = translation
        self.transcription = transcription
        self.comment = comment
        self.sample = sample
    }
}

protocol IConfigurableTranslationCell {
    func setup(config: ITranslationCellConfiguration)
}


class TranslationTableViewCell: UITableViewCell, IConfigurableTranslationCell, ITranslationCellConfiguration, UITextViewDelegate {
    
    public class func cellId() -> String {
        return "TranslationCellId"
    }
    
    var translation: String?
    
    var transcription: String?
    
    var comment: String?
    
    var sample: String?
    
    var delegate: ITranslationCellDidChangeDelegate?
    
    func updateUI() {
        self.translationTextField.text = translation
        self.transcriptionTextField.text = transcription
        self.commentTextField.text = comment
        self.sampleTextField.text = sample
    }
    
    func setup(config: ITranslationCellConfiguration) {
        self.translation = config.translation
        self.comment = config.comment
        self.sample = config.sample
        self.transcription = config.transcription
        
        updateUI()
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [translationContainerView, transcriptionContainerView, commentContainerView, self.sampleContainer])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        
        return stackView
    }()
    
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        view.addSubview(self.speakButton)
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 22, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        
        self.speakButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: -0)
        
        return view
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        //self.contentView.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        self.contentView.addSubview(baseShadowView)
        
        baseShadowView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var translationTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = "Перевод"
        tf.font = UIFont.systemFont(ofSize: 18)
        
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return tf
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }
    
    lazy var commentTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.placeholder = "Комментарий"
        tf.layer.borderWidth = 0
        tf.font = UIFont.systemFont(ofSize: 18)
        
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return tf
    }()
    
    lazy var transcriptionTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = "Транскрипция"
        tf.font = UIFont.systemFont(ofSize: 18)
        
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return tf
    }()
    
    let sampleTextViewPlaceholder = "Пример"
    
    lazy var sampleTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = sampleTextViewPlaceholder
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return tf
    }()
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.update(caller: self, newConf: generateCellConf())
    }
    
    func generateCellConf() -> TranslationCellConfiguration {
        return TranslationCellConfiguration(translation: self.translationTextField.text, transcription: self.transcriptionTextField.text, comment: self.commentTextField.text, sample: self.sampleTextField.text)
    }
    
    lazy var sampleContainer: UIView = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Пример:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextFieldWithLabel(textField: sampleTextField, label: label, spacing: 2)
        return view
    }()
    
    lazy var commentContainerView: UIView = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Комментарий:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextFieldWithLabel(textField: commentTextField, label: label, spacing: 2)
        return view
    }()
    
    lazy var transcriptionContainerView: UIView = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Транскрипция:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextFieldWithLabel(textField: transcriptionTextField, label: label, spacing: 2)
        return view
    }()
    
    lazy var translationContainerView: UIView = {
       let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
       label.text = "Перевод:"
       label.font = .systemFont(ofSize: 15, weight: .light)
       label.textColor = .gray
       
       let view = UITextFieldWithLabel(textField: translationTextField, label: label, spacing: 2)
       return view
    }()
    
    lazy var speakButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        
        button.setImage(#imageLiteral(resourceName: "volume"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "volume-1"), for: UIControl.State.focused)
        
        button.addTarget(self, action: #selector(onSpeakButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    @objc func onSpeakButtonPressed() {
        AVSpeechSynthesizer().speak(AVSpeechUtterance(string: self.translationTextField.text ?? ""))
    }
}
