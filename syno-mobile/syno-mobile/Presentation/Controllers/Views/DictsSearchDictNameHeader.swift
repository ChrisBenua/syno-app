//
//  DictsSearchDictNameHeader.swift
//  syno-mobile
//
//  Created by Christian Benua on 17.01.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class DictsSearchDictNameHeader: UICollectionViewCell {
    static let headerId = String(describing: DictsSearchDictNameHeader.self)
    
    lazy var dictionaryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .dictsSearchHeaderMainColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(dictionaryNameLabel)
        dictionaryNameLabel.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, padding: .init(top: 10, left: 5, bottom: 4, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
