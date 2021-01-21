import Foundation
import UIKit

/// Default view with shadow
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
    
    var isAnimatable: Bool = false
    
    var animationDuration: TimeInterval = 0.5
    
    /// Setting up shadow
    func setupShadow() {
        self.layer.cornerRadius = cornerRadius ?? 8

        self.layer.shadowColor = UIColor.gray.cgColor
        
        self.layer.shadowOffset = shadowOffset ?? CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = shadowRadius ?? 5
        self.layer.shadowOpacity = 0.3
        
        if (isAnimatable) {
            let theAnimation = CABasicAnimation(keyPath: "shadowPath")
            theAnimation.duration = animationDuration;
            theAnimation.fillMode = .forwards
            theAnimation.isRemovedOnCompletion = false
            theAnimation.fromValue = self.layer.presentation()?.shadowPath ?? UIBezierPath(roundedRect: .zero, cornerRadius: 0).cgPath
            Logger.log("\(theAnimation.fromValue)")
            theAnimation.toValue = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: self.layer.cornerRadius, height: self.layer.cornerRadius)).cgPath;
            Logger.log("\(theAnimation.fromValue)")
            theAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.layer.add(theAnimation, forKey: "shadowAnimation")
        } else {
            self.layer.removeAnimation(forKey: "shadowAnimation")
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: self.layer.cornerRadius, height: self.layer.cornerRadius)).cgPath
        }
        
        self.layer.shouldRasterize = true
    }
}
