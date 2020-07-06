//
//  UIButtonExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 30.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func flash(key: String? = nil, fromValue: CGFloat = 1, toValue: CGFloat = 0.1, duration: CFTimeInterval = 0.5) {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = duration
        flash.fromValue = fromValue
        flash.toValue = toValue
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 1
        
        layer.add(flash, forKey: key)
    }
}

