import Foundation
import UIKit

extension UIColor {
    /// Main background color for UITextField
    static let textFieldsMainColor = UIColor(red: 235.0 / 255, green: 235.0 / 255, blue: 235.0 / 255, alpha: 1.0)

    /// Main Color for buttons with submit meaning
    static let submitButtonMainColor = UIColor(red: 38.0 / 255, green: 90.0 / 255, blue: 138.0 / 255, alpha: 1.0)
    
    /// Main text color for highlighted text
    static let headerMainColor = UIColor(red: 81.0/255, green: 110.0/255, blue: 139.0/255, alpha: 1.0)
    
    static let dictsSearchHeaderMainColor = #colorLiteral(red: 0.2286044974, green: 0.3248293059, blue: 0.4210541144, alpha: 1)
    
    static let highlightTextColor: UIColor = #colorLiteral(red: 0.9979823232, green: 0.5370767117, blue: 0.007075123955, alpha: 1)
    
    static let playButtonColor: UIColor = #colorLiteral(red: 0.5281257629, green: 0.6345871091, blue: 0.7730612159, alpha: 1)
    
    /// Alternative button color
    static let anotherButtonMainColor = UIColor(red: 96.0/255, green: 157.0/255, blue: 248.0/255, alpha: 1.0)
    
    func makeDarkerBy(steps: CGFloat) -> UIColor {
      var red: CGFloat = 0
      var green: CGFloat = 0
      var blue: CGFloat = 0
      var alpha: CGFloat = 0
      
      self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      red = min(1, max(red + steps, 0))
      green = min(1, max(green + steps, 0))
      blue = min(1, max(blue + steps, 0))
      alpha = min(1, max(alpha + steps, 0))
      return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
      var colorStr = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
      
      if (colorStr.hasPrefix("#")) {
        colorStr.removeFirst()
      }
      
      if colorStr.count != 6 {
        self.init(hex: "ff0000") // return red color for wrong hex input
        return
      }
      var rgbValue: UInt64 = 0
      Scanner(string: colorStr).scanHexInt64(&rgbValue)
      
      self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha)
    }
}
