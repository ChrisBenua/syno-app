//
//  SavingProcessView.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 29.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class SavingProcessView: UIView {
    
    func dismissSavingProcessView() {
        self.activityIndicator.stopAnimating()
        self.removeFromSuperview()
    }
    
    func showSavingProcessView(sourceView: UIViewController) {
        sourceView.view.addSubview(self)
        self.activityIndicator.startAnimating()
        self.centerYAnchor.constraint(equalTo: sourceView.view.centerYAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: sourceView.view.centerXAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: sourceView.view.heightAnchor, multiplier: 0.13).isActive = true
        self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
    }
    
    let savingLabel: UILabel = {
        let label = UILabel()
        label.text = "Saving..."
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setText(text: String) {
        savingLabel.text = text
    }
    
    lazy var activityIndicator = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
        self.alpha = 0.7
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.addSubview(activityIndicator)
        self.addSubview(savingLabel)
        
        
        savingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        savingLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        
        //label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
