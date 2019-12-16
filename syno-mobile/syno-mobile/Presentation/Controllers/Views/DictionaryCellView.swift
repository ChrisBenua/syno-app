//
//  DictionaryCellView.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol IDictionaryCellConfiguration: class {
    var dictName: String? { get set }
    var language: String? { get set }
    var cardsAmount: Int { get set }
    var translationsAmount: Int { get set }
}

class DictionaryCellConfiguration: IDictionaryCellConfiguration {
    var dictName: String?
    
    var language: String?
    
    var cardsAmount: Int
    
    var translationsAmount: Int
    
    init(dictName: String?, language: String?, cardsAmount: Int, translationsAmount: Int) {
        self.dictName = dictName
        self.language = language
        self.cardsAmount = cardsAmount
        self.translationsAmount = translationsAmount
    }
}

protocol IConfigurableDictionaryCell: IDictionaryCellConfiguration {
    func setup(dictName: String, language: String, cardsAmount: Int, translationsAmount: Int)
    func setup(config: IDictionaryCellConfiguration)
}

class DictionaryCollectionViewCell: UICollectionViewCell, IConfigurableDictionaryCell {
    public static let cellId = "DictCellID"
    
    func setup(dictName: String, language: String, cardsAmount: Int, translationsAmount: Int) {
        self.dictName = dictName
        self.language = language
        self.cardsAmount = cardsAmount
        self.translationsAmount = translationsAmount
        
        updateUI()
    }
    
    func setup(config: IDictionaryCellConfiguration) {
        setup(dictName: config.dictName ?? "", language: config.language ?? "", cardsAmount: config.cardsAmount, translationsAmount: config.translationsAmount)
    }
    
    func updateUI() {
        self.nameLabel.text = self.dictName
        self.languageLabel.text = self.language
        self.cardsAmountLabel.text = "\(cardsAmount) cards"
        self.translationsAmountLabel.text = "\(translationsAmount) translations"
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundView = UIImageView(image: #imageLiteral(resourceName: "DictCellBackgroung"))
        //self.backgroundColor = UIColor.init(red: 239.0/255, green: 239.0/255, blue: 239.0/255, alpha: 1.0)
        
        let transAndLangStackView = UIStackView(arrangedSubviews: [translationsAmountLabel, languageLabel])
        transAndLangStackView.axis = .horizontal;transAndLangStackView.translatesAutoresizingMaskIntoConstraints = false
        transAndLangStackView.distribution = .fillProportionally
        
        
        let mainSV = UIStackView(arrangedSubviews: [nameLabel, cardsAmountLabel, transAndLangStackView])
        mainSV.axis = .vertical; mainSV.translatesAutoresizingMaskIntoConstraints = false
        mainSV.distribution = .fill
        nameLabel.heightAnchor.constraint(equalTo: mainSV.heightAnchor, multiplier: 0.4).isActive = true
        transAndLangStackView.heightAnchor.constraint(equalTo: cardsAmountLabel.heightAnchor, multiplier: 1).isActive = true
        
        self.contentView.addSubview(mainSV)
        mainSV.spacing = 10
        mainSV.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 23, paddingRight: 15, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dictName: String?
    
    var language: String?
    
    var cardsAmount: Int = -1
    
    var translationsAmount: Int = -1
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .headerMainColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let languageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .right
        
        return label
    }()
    
    let cardsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .left
        
        return label
    }()
    
    let translationsAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .left
        
        return label
    }()
    
}
