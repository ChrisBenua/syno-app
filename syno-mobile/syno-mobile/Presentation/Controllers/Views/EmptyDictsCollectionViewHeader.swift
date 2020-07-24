//
//  EmptyDictsCollectionViewHeader.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 17.07.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class EmptyDictsCollectionViewHeader: UICollectionViewCell {
    static let headerId = "EmptyDictsCollectionViewHeaderШв"

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26)
        label.textColor = .lightGray
        label.numberOfLines = 3
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.text = "Пока у Вас нет Словарей\nНажмите на '+' для создания Словаря"
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(label)
        label.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
