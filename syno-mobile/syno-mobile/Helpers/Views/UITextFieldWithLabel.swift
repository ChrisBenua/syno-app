//
//  UITextFieldWithLabel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 07.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class UITextFieldWithLabel: UIView {
    private var textField: UITextField
    private var label: UILabel
    private var spacing: CGFloat
    
    private func layout() {
        let sv = UIStackView(arrangedSubviews: [label, textField])
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        sv.spacing = spacing
        
        self.addSubview(sv)
        sv.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    init(textField: UITextField, label: UILabel, spacing: CGFloat) {
        self.textField = textField
        self.label = label
        self.spacing = spacing
        super.init(frame: .zero)
        layout()
    }
    
    init() {
        self.textField = UITextField()
        self.label = UILabel()
        self.spacing = 1
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleTextField(styleFunc: (UITextField) -> ()) {
        styleFunc(textField)
    }
    
    func styleLabel(styleFunc: (UILabel) -> ()) {
        styleFunc(label);
    }
    
    func getTextField() -> UITextField {
        return textField
    }
    
    func getLabel() -> UILabel {
        return label
    }
    
}
