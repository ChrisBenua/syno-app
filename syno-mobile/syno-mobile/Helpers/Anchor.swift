import Foundation
import UIKit

extension UIView {
    
    /**
     Anchoring object of UIView to Top Left Bottom Right
     - Parameter top: view's topAnchor to top, Optional
     - Parameter left: view's leftAnchor to left, Optional
     - Parameter bottom: view's bottomAnchor to bottom, Optional
     - Parameter right: view's topAnchor to right, Optional
     - Parameter paddingTop: padding constant from topAnchor
     - Parameter paddingLeft: padding constant from leftAnchor
     - Parameter paddingBottom: padding constant from bottomAnchor
     - Parameter paddingRight: padding constant from rightAnchor
     - Parameter height: if one of Top or Bottom anchors isn't set, you have to set height explicitly
     - Parameter width: if one of Left or Right anchor isn't set, you have to set width explicitly
     */
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}


