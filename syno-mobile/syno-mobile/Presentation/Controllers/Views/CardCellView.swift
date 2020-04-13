//
//  CardCellView.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 12.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ICardCellConfiguration {
    var translatedWord: String? { get set }
    var translations: [String]? { get set }
}

class CardCellConfiguration: ICardCellConfiguration {
    var translatedWord: String?
    
    var translations: [String]?
    
    init(translatedWord: String?, translations: [String]?) {
        self.translatedWord = translatedWord
        self.translations = translations
    }
}

protocol IConfigurableCardCell {
    func setup(configuration: ICardCellConfiguration)
}

class CardCollectionViewCell: UICollectionViewCell, IConfigurableCardCell {
    public static let cellId = "CardCellID"

    var translatedWord: String?
    var translations: [String]?
    
    func updateUI() {
        self.translatedWordLabel.text = translatedWord
        var translationsText = (translations ?? []).reduce("", { (res, curr) -> String in
            return res + "," + curr
        })
        
        if translationsText.count > 0 {
            let index = translationsText.index(after: translationsText.startIndex)
            translationsText = String(translationsText[index...])
        }
        
        self.translationsLabel.text = translationsText
    }
    
    func setup(configuration: ICardCellConfiguration) {
        self.translatedWord = configuration.translatedWord
        self.translations = configuration.translations
        
        updateUI()
    }
    
    let translatedWordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .headerMainColor
        
        label.textAlignment = .left
        return label
    }()
    
    let translationsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundView = UIImageView(image: #imageLiteral(resourceName: "CardCellBackground"))
        
        self.contentView.addSubview(translatedWordLabel)
        
        translatedWordLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        
        self.contentView.addSubview(translationsLabel)
        translatedWordLabel.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.translationsLabel.leftAnchor, paddingTop: 2, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
        
        translationsLabel.anchor(top: self.contentView.topAnchor, left: nil, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 5, paddingRight: 10, width: 0, height: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
