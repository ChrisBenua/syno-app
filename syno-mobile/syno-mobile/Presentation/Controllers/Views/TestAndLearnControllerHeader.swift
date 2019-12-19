//
//  TestAndLearnControllerHeader.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol ITestAndLearnHeaderDelegate: class {
    func onSegmentChanged()
}

class TestAndLearnControllerHeader: UICollectionViewCell {
    static let headerId = "TestAndLearnControllerHeaderId"
    
    weak var delegate: ITestAndLearnHeaderDelegate?
    
    private let selectedSegmentTintColor = UIColor.init(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1)
    
    lazy var segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Обучение", "Тест"])
                
        control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .selected)
        
        control.tintColor = UIColor.init(red: 239.0/255, green: 239.0/255, blue: 239.0/255, alpha: 1)
        if #available(iOS 13.0, *) {
            control.selectedSegmentTintColor = selectedSegmentTintColor
        } else {
            // Fallback on earlier versions
            control.updateColors(selectedColor: selectedSegmentTintColor)
        }
        control.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)
        
        return control
    }()
    
    @objc func onSegmentChanged() {
        if #available(iOS 13.0, *) {
        } else {
            segmentControl.updateColors(selectedColor: selectedSegmentTintColor)
        }
        self.delegate?.onSegmentChanged()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = UIView()
        view.addSubview(segmentControl)
        let widthMult: CGFloat = 0.7
        self.segmentControl.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        self.contentView.addSubview(view)
        view.anchor(top: self.contentView.topAnchor, left: nil, bottom: self.contentView.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        view.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: widthMult).isActive = true
        view.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
