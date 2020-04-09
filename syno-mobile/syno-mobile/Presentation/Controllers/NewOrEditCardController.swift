//
//  NewOrEditCardController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 08.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit


class NewOrEditCardController: UIViewController {
    lazy var translationTextView: UITextViewWithLabel = {
        var textView = UITextView()
        textView.clipsToBounds = true; textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 21)
        textView.isScrollEnabled = false
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Перевод:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextViewWithLabel(textView: textView, label: label, spacing: 5)
        
        return view
    }()
    
    lazy var transcriptionTextView: UITextViewWithLabel = {
        var textView = UITextView()
        textView.clipsToBounds = true; textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 21)
        textView.isScrollEnabled = false
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Транскрипция:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextViewWithLabel(textView: textView, label: label, spacing: 5)
        
        return view
    }()
    
    lazy var commentTextView: UITextViewWithLabel = {
        var textView = UITextView()
        textView.clipsToBounds = true; textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 21)
        textView.isScrollEnabled = false
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Комментарий:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextViewWithLabel(textView: textView, label: label, spacing: 5)
        
        return view
    }()
    
    lazy var sampleTextView: UITextViewWithLabel = {
        var textView = UITextView()
        textView.clipsToBounds = true; textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 21)
        textView.isScrollEnabled = false
        
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        label.text = "Пример:"
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        
        let view = UITextViewWithLabel(textView: textView, label: label, spacing: 5)
        
        return view
    }()

    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.translationTextView, self.transcriptionTextView, self.commentTextView, self.sampleTextView])
        view.axis = .vertical
        view.distribution = .fillProportionally
        
        view.spacing = 20
        
        return view
    }()
    
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 22, paddingLeft: 15, paddingBottom: 20, paddingRight: 15, width: 0, height: 0)
        
        return view
    }()
    
    lazy var submitButton: UIButton = {
        let button = CommonUIElements.defaultSubmitButton(text: "Добавить", cornerRadius: 10, backgroundColor: UIColor.anotherButtonMainColor, borderColor: UIColor.clear.cgColor, textColor: UIColor.black)
        button.addTarget(self, action: #selector(onSubmitCard), for: .touchUpInside)
        
        return button
    }()
    
    @objc func onSubmitCard() {
        Logger.log("submitCard")
    }
    
    lazy var contentView: UIView = {
        let view = UIStackView(arrangedSubviews: [self.baseShadowView, self.submitButton])
        view.axis = .vertical
        view.distribution = .fillProportionally
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(self.contentView)
        
        self.contentView.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: nil, bottom: scrollView.contentLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationItem.title = "Новая карточка"
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
    }
    
}
