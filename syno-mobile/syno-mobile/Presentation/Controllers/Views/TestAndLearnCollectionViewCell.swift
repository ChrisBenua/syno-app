//
//  TestAndLearnCollectionViewCell.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ITestAndLearnCellConfiguration {
    var dictionaryName: String? { get }
    var language: String? { get }
    var gradePercentage: Double { get }
    
    func gradeToStringAndColor() -> (String, UIColor)
}

class TestAndLearnCellConfiguration: ITestAndLearnCellConfiguration {
    var dictionaryName: String?
    
    var language: String?
    
    var gradePercentage: Double
    
    init(dictionaryName: String?, language: String?, gradePercentage: Double) {
        self.dictionaryName = dictionaryName
        self.language = language
        self.gradePercentage = gradePercentage
    }
    
    func gradeToStringAndColor() -> (String, UIColor) {
        let colors = [UIColor(red: 244.0/255, green: 203.0/255, blue: 205.0/255, alpha: 1),
                      UIColor(red: 253.0/255, green: 214.0/255, blue: 190.0/255, alpha: 1),
                      UIColor(red: 254.0/255, green: 236.0/255, blue: 188.0/255, alpha: 1),
                      UIColor(red: 201.0/255, green: 236.0/255, blue: 213.0/255, alpha: 1),
                      UIColor(red: 198.0/255, green: 251.0/255, blue: 205.0/255, alpha: 1)
        ]
        let colorsRange = [20.0, 40.0, 60.0, 80.0, 100.0]
        let colorIndex = colorsRange.firstIndex { (val) -> Bool in
            val <= gradePercentage + 0.0001
        }
        let color = colorIndex == nil ? UIColor.black : colors[colorIndex!]
        
        let str = self.gradePercentage > -0.5 ? "\(Int(self.gradePercentage))" : "N/A"
        
        return (str, color)
    }
}

protocol IConfigurableTestAndLearnCell {
    func setup(config: ITestAndLearnCellConfiguration)
}

class TestAndLearnCollectionViewCell: UICollectionViewCell, IConfigurableTestAndLearnCell {
    static let cellId = "TestAndLearnCollectionViewCellId"
    var config: ITestAndLearnCellConfiguration?
    
    lazy var gradeAndLanguageView: UIView = {
        let view = UIView()
        view.addSubview(self.gradeLabel)
        view.addSubview(self.languageLabel)
        
        self.gradeLabel.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 0)
        self.gradeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        self.languageLabel.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        return view
    }()
    
    let gradeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        
        return label
    }()
    
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
    
    lazy var stackView: UIStackView = {
        let sepView = UIView();sepView.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView(arrangedSubviews: [self.nameLabel, sepView, self.gradeAndLanguageView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
        
        sepView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.3).isActive = true
        
        return stackView
    }()
    
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.stackView)
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, paddingRight: 20, width: 0, height: 0)
        
        return view
    }()
    
    func updateUI() {
        self.gradeLabel.text = self.config?.gradeToStringAndColor().0
        if self.config != nil {
            self.gradeLabel.textColor = self.config!.gradeToStringAndColor().1
        }
        self.nameLabel.text = self.config?.dictionaryName
        self.languageLabel.text = self.config?.language
    }
    
    func setup(config: ITestAndLearnCellConfiguration) {
        self.config = config
        updateUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(baseShadowView)
        
        baseShadowView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
