import Foundation
import UIKit

/// Class for generating string and color for grades
class GradeToStringAndColor {
    /// Converts grade to color
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
    
    static func strictGradeToColor(gradePercentage: Double) -> UIColor {
        let colors = [#colorLiteral(red: 0.4797319953, green: 0.6705882353, blue: 0.3921568627, alpha: 1),
                      #colorLiteral(red: 0.9607843137, green: 0.5321290219, blue: 0.5392732768, alpha: 1)]
        let colorsRange = [99.0, 0.0]
        let colorIndex = colorsRange.firstIndex { (val) -> Bool in
            val <= gradePercentage + 0.0001
        }
        let color = colorIndex == nil ? UIColor.black : colors[colorIndex!]
        
        return color
    }
    
    /// Converts grade to string description and color
    static func gradeToStringAndColor(gradePercentage: Double) -> (String, UIColor) {
        let str = gradePercentage > -0.5 ? "\(Int(gradePercentage))%" : "N/A"
        
        return (str, gradeToColor(gradePercentage: gradePercentage))
    }
}
