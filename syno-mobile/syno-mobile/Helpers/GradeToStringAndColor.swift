import Foundation
import UIKit

/// Class for generating string and color for grades
class GradeToStringAndColor {
    /// Converts grade to color
    static func gradeToColor(gradePercentage: Double) -> UIColor {
        let colors = GradeColors.colors
        let colorsRange = [80.0, 60.0, 40.0, 0.0]
        let colorIndex = colorsRange.firstIndex { (val) -> Bool in
            val <= gradePercentage + 0.0001
        }
        let color = colorIndex == nil ? UIColor.black : colors[colorIndex!]
        
        return color
    }
    
    static func strictGradeToColor(gradePercentage: Double) -> UIColor {
        let colors = GradeColors.strictColors
        let colorsRange = [99.0, 0.0]
        let colorIndex = colorsRange.firstIndex { (val) -> Bool in
            val <= gradePercentage + 0.0001
        }
        let color = colorIndex == nil ? UIColor.black : colors[colorIndex!]
        
        return color
    }
    
    /// Converts grade to string description and color
    static func gradeToStringAndColor(gradePercentage: Double) -> (String, UIColor, Bool) {
        let str = gradePercentage > -0.5 ? "\(Int(gradePercentage))%" : "Нет результата"
        
        return (str, gradeToColor(gradePercentage: gradePercentage), gradePercentage > -0.5)
    }
    
    private enum GradeColors {
        private static let green = UIColor(red: 137.0/255, green: 190.0/255, blue: 113.0/255, alpha: 1)
        private static let red = UIColor(red: 239.0/255, green: 165.0/255, blue: 167.0/255, alpha: 1)
        
        static let strictColors = [green, red]
        static let colors = [
            green,
            UIColor(red: 225.0/255, green: 209.0/255, blue: 124.0/255, alpha: 1.0),
            UIColor(red: 238.0/255, green: 191.0/255, blue: 148.0/255, alpha: 1.0),
            red
        ]
    }
}
