//
//  ShadowView.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class ShadowView: UIView {
    
    /// When bounds are set, we update Shadows
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    var shadowRadius: CGFloat?
    
    var cornerRadius: CGFloat?
    
    var shadowOffset: CGSize?
    
    /// Setting up shadow
    func setupShadow() {
        print(bounds)
        self.layer.cornerRadius = cornerRadius ?? 8

        self.layer.shadowColor = UIColor.gray.cgColor
        
        self.layer.shadowOffset = shadowOffset ?? CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = shadowRadius ?? 5
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: self.layer.cornerRadius, height: self.layer.cornerRadius)).cgPath
        self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.main.scale
    }
}
