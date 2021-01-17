import Foundation
import UIKit


class ClickableUILabel: UILabelWithInsets {
    private var configuration: Configuration! {
        didSet {
            self.backgroundColor = .clear
            self.layer.backgroundColor = configuration.backgroundColor.cgColor
        }
    }
    
    func setConfiguration(config: Configuration) {
        self.configuration = config
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        Logger.log(#function)
        UIView.animate(withDuration: configuration.animationDuration) {
            if self.configuration.parentAnimationDepth == 0 {
                self.transform = self.configuration.transform
            } else {
                var view = self.superview
                for _ in 0..<self.configuration.parentAnimationDepth {
                    Logger.log("\(view == nil)")
                    view = view?.superview
                }
                
                view?.transform = self.configuration.transform
            }
            self.layer.backgroundColor = self.configuration.pressedBackgroundColor.cgColor
        }
      
        super.touchesBegan(touches, with: event)
    }
      
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        Logger.log(#function)
        UIView.animate(withDuration: configuration.animationDuration) {
            if self.configuration.parentAnimationDepth == 0 {
                self.transform = .identity
            } else {
                var view = self.superview
                for _ in 0..<self.configuration.parentAnimationDepth {
                    Logger.log("\(view == nil)")
                    view = view?.superview
                }
                
                view?.transform = .identity
            }
            
            self.layer.backgroundColor = self.configuration.backgroundColor.cgColor
        }
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Logger.log(#function)
        UIView.animate(withDuration: configuration.animationDuration) {
            if self.configuration.parentAnimationDepth == 0 {
                self.transform = .identity
            } else {
                var view = self.superview
                for _ in 0..<self.configuration.parentAnimationDepth {
                    Logger.log("\(view == nil)")
                    view = view?.superview
                }
                
                view?.transform = .identity
            }
            
            self.layer.backgroundColor = self.configuration.backgroundColor.cgColor
        }
        super.touchesEnded(touches, with: event)
    }
    
    class Configuration {
        var transform: CGAffineTransform
        var backgroundColor: UIColor
        var pressedBackgroundColor: UIColor
        var animationDuration: TimeInterval
        var parentAnimationDepth: Int = 0
        
        init(transform: CGAffineTransform, backgroundColor: UIColor, pressedBackgroundColor: UIColor, animationDuration: TimeInterval, parentAnimationDepth: Int = 0) {
            self.transform = transform
            self.backgroundColor = backgroundColor
            self.pressedBackgroundColor = pressedBackgroundColor
            self.animationDuration = animationDuration
            self.parentAnimationDepth = parentAnimationDepth
        }
        
        class Builder {
            private var transform: CGAffineTransform = .init(scaleX: 0.96, y: 0.96)
            private var backgroundColor: UIColor = UIColor.white
            private var pressedBackgroundColor: UIColor = UIColor.white.makeDarkerBy(steps: -0.07)
            private var animationDuration: TimeInterval = 0.6
            private var parentAnimationDepth: Int = 0
            
            func transform(_ transform: CGAffineTransform) -> Self {
                self.transform = transform
                return self
            }
            
            func backgroundColor(_ color: UIColor) -> Self {
                self.backgroundColor = color
                return self
            }
            
            func pressedBackgroundColor(_ color: UIColor) -> Self {
                self.pressedBackgroundColor = color
                return self
            }
            
            func animationDuration(_ duration: TimeInterval) -> Self {
                self.animationDuration = duration
                return self
            }
            
            func parentAnimationDepth(_ depth: Int) -> Self {
                self.parentAnimationDepth = depth
                return self
            }
            
            func build() -> Configuration {
                return Configuration(transform: transform, backgroundColor: backgroundColor, pressedBackgroundColor: pressedBackgroundColor, animationDuration: animationDuration, parentAnimationDepth: parentAnimationDepth)
            }
        }
    }
}

/// Simple Label with needed padding from top left bottom right(UIEdgeInset)
class UILabelWithInsets: UILabel {
    /// Paddings from bounds
    let padding: UIEdgeInsets
    
    /// Create a new UILabelWithInsets instance programamtically with the desired insets
    required init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) {
        self.padding = padding
        super.init(frame: CGRect.zero)
    }
    
    /// Create a new UILabelWithInsets instance programamtically with default insets
    override init(frame: CGRect) {
        padding = UIEdgeInsets.zero
        super.init(frame: frame)
    }
    
    /// Create a new `UILabelWithInsets` instance from Storyboard with default insets
    required init?(coder aDecoder: NSCoder) {
        padding = UIEdgeInsets.zero
        super.init(coder: aDecoder)
    }
    
    /// Draws text in rect with insets
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.padding))
    }
    
    /// Override `intrinsicContentSize` property for Auto layout code
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
    /// Override `sizeThatFits(_:)` method for Springs & Struts code
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let heigth = superSizeThatFits.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
}
