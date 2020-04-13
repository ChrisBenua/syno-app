//
//  GradeToStringAndColor.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 11.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class GradeToStringAndColor {
    
    static func gradeToColor(gradePercentage: Double) -> UIColor {
        let colors = [UIColor(red: 18.0/255, green: 171.0/255, blue: 79.0/255, alpha: 1),
                      UIColor(red: 134.0/255, green: 240.0/255, blue: 0.0/255, alpha: 1),
                      UIColor(red: 198.0/255, green: 211.0/255, blue: 49.0/255, alpha: 1),
            UIColor(red: 245/255, green: 89/255, blue: 89/255, alpha: 1)]
        let colorsRange = [80.0, 60.0, 40.0, 0.0]
        let colorIndex = colorsRange.firstIndex { (val) -> Bool in
            val <= gradePercentage + 0.0001
        }
        let color = colorIndex == nil ? UIColor.black : colors[colorIndex!]
        
        return color
    }
    
    static func gradeToStringAndColor(gradePercentage: Double) -> (String, UIColor) {
        let str = gradePercentage > -0.5 ? "\(Int(gradePercentage))%" : "N/A"
        
        return (str, gradeToColor(gradePercentage: gradePercentage))
    }
}
