//
//  TranslationCollectionViewCell.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
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
        let stackView = UIStackView(arrangedSubviews: [translationTextField, transcriptionTextField, commentTextField, self.sampleTextField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 18
        
        return stackView
    }()
    
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        
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
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = "Перевод"
        tf.font = UIFont.systemFont(ofSize: 18)
        
        return tf
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }
    
    lazy var commentTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0))
        tf.placeholder = "Комментарий"
        tf.layer.borderWidth = 0
        tf.font = UIFont.systemFont(ofSize: 18)
        
        return tf
    }()
    
    lazy var transcriptionTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = "Транскрипция"
        tf.font = UIFont.systemFont(ofSize: 18)
        
        return tf
    }()
    
    let sampleTextViewPlaceholder = "Пример"
    
    lazy var sampleTextField: UITextField = {
        let tf = CommonUIElements.defaultTextField(backgroundColor: .white, edgeInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 0))
        tf.layer.borderWidth = 0
        tf.placeholder = sampleTextViewPlaceholder
        
        return tf
    }()
}
