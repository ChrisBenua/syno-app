import Foundation
import UIKit

struct CustomUIButtonConfiguration {
  let animationDuration: CFTimeInterval
  let basicShadowRadius: CGFloat
  let pressedShadowRadius: CGFloat
  let shadowColor: CGColor
  let shadowOpacity: Float
  let cornerRadius: CGFloat
  let backgroundColor: CGColor
  let pressedBackgroundColor: CGColor
  let disabledBackgroundColor: CGColor
  let buttonTransform: CGAffineTransform
}

class CustomUIButtonConfigurationBuilder {
  private var animationDuration: CFTimeInterval = 0.2
  private var basicShadowRadius: CGFloat = 0
  private var pressedShadowRadius: CGFloat = 4
  private var shadowColor: CGColor = UIColor.init(white: 0.4, alpha: 1).cgColor
  private var shadowOpacity: Float = 1
  private var cornerRadius: CGFloat = 10
  private var backgroundColor: CGColor = UIColor.systemBlue.cgColor
  private var pressedBackgroundColor: CGColor = UIColor.systemBlue.makeDarkerBy(steps: 0.04).cgColor
  private var disabledBackgroundColor: CGColor = UIColor.init(hex: "A1A1A1").cgColor
  private var buttonTransform: CGAffineTransform = .init(scaleX: 0.97, y: 0.97)

  
  func setAnimationDuration(_ duration: CFTimeInterval) -> Self {
    self.animationDuration = duration
    return self
  }
  
  func setBasicShadowRadius(_ radius: CGFloat) -> Self {
    self.basicShadowRadius = radius
    return self
  }
  
  func setPressedShadowRadius(_ radius: CGFloat) -> Self {
    self.pressedShadowRadius = radius
    return self
  }
  
  func setShadowColor(_ color: CGColor) -> Self {
    self.shadowColor = color
    return self
  }
  
  func setShadowOpacity(_ opacity: Float) -> Self {
    self.shadowOpacity = opacity
    return self
  }
  
  func setCornerRadius(_ radius: CGFloat) -> Self {
    self.cornerRadius = radius
    return self
  }
  
  func setBackgroundColor(_ color: CGColor) -> Self {
    self.backgroundColor = color
    return self
  }
  
  func setPressedBackgroundColor(_ color: CGColor) -> Self {
    self.pressedBackgroundColor = color
    return self
  }
  
  func setButtonTransform(_ transform: CGAffineTransform) -> Self {
    self.buttonTransform = transform
    return self
  }
  
  func setDisabledColor(_ color: CGColor) -> Self {
    self.disabledBackgroundColor = color
    return self
  }
  
  func build() -> CustomUIButtonConfiguration {
    return CustomUIButtonConfiguration(animationDuration: animationDuration, basicShadowRadius: basicShadowRadius, pressedShadowRadius: pressedShadowRadius, shadowColor: shadowColor, shadowOpacity: shadowOpacity, cornerRadius: cornerRadius, backgroundColor: backgroundColor, pressedBackgroundColor: pressedBackgroundColor, disabledBackgroundColor: disabledBackgroundColor, buttonTransform: buttonTransform)
  }
}

class CustomUIButton: UIButton {
  
  private var shadowLayer: CAShapeLayer!
  private var configuration_: CustomUIButtonConfiguration!
  
  override var isEnabled: Bool {
    willSet {
      if newValue != isEnabled {
        Logger.log("animation ISENABLED: \(isEnabled) \(newValue)")
        self.animateButtonColor(key: "fillColor", toColor: newValue ? self.configuration_.backgroundColor : self.configuration_.disabledBackgroundColor)
      }
    }
  }
  
  private func animateButtonColor(key: String, toColor: CGColor) {
    let keyPath = "fillColor"
    let animation = CABasicAnimation(keyPath: keyPath)
    //Logger.log("\(self.shadowLayer?.fillColor?.components)")
    animation.fromValue = self.shadowLayer?.presentation()?.fillColor
    animation.toValue = toColor
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false
    animation.duration = self.configuration_.animationDuration * 2
    self.shadowLayer?.removeAnimation(forKey: key)
    self.shadowLayer?.add(animation, forKey: key)
  }
  
  private func animateIn() {
    Logger.log(#function)
    let key = "shadowRadiusIn"
    let animation = CABasicAnimation(keyPath: "shadowRadius")
    animation.fromValue = self.shadowLayer.shadowRadius
    animation.toValue = self.configuration_.pressedShadowRadius
    animation.isRemovedOnCompletion = false
    animation.fillMode = .forwards
    animation.duration = self.configuration_.animationDuration
    
    for key in [key, "shadowRadiusOut"] {
      self.shadowLayer.removeAnimation(forKey: key)
    }
    self.shadowLayer.add(animation, forKey: key)
    
    let key2 = "fillColorIn"
    let animation2 = CABasicAnimation(keyPath: "fillColor")
    animation2.fromValue = self.shadowLayer.presentation()!.fillColor
    animation2.toValue = configuration_.pressedBackgroundColor
    animation2.isRemovedOnCompletion = false
    animation2.fillMode = .forwards
    animation2.duration = self.configuration_.animationDuration
    
    for key in [key2, "fillColorOut"] {
      self.shadowLayer.removeAnimation(forKey: key)
    }
    self.shadowLayer.add(animation2, forKey: key2)
  }
  
  private func animateOut() {
    Logger.log(#function)
    Logger.log("shadowRadius: \(self.shadowLayer.shadowRadius), \(self.shadowLayer.presentation()?.value(forKeyPath: "shadowRadius") ?? -1)")
    let key = "shadowRadiusOut"
    let removeKeys = [key, "shadowRadiusIn"]
    let animation = CABasicAnimation(keyPath: "shadowRadius")
    animation.fromValue = self.shadowLayer.presentation()?.value(forKeyPath: "shadowRadius") ?? 4
    animation.toValue = self.configuration_.basicShadowRadius
    animation.isRemovedOnCompletion = false
    animation.fillMode = .forwards
    animation.duration = self.configuration_.animationDuration
    
    for key in removeKeys {
      self.shadowLayer.removeAnimation(forKey: key)
    }
    self.shadowLayer.add(animation, forKey: key)
    
    let key2 = "fillColorOut"
    let animation2 = CABasicAnimation(keyPath: "fillColor")
    animation2.fromValue = self.shadowLayer.presentation()?.value(forKeyPath: "fillColor")
    animation2.toValue = configuration_.backgroundColor
    animation2.isRemovedOnCompletion = false
    animation2.fillMode = .forwards
    animation2.duration = self.configuration_.animationDuration
    
    for key in [key2, "fillColorIn"] {
      self.shadowLayer.removeAnimation(forKey: key)
    }
    self.shadowLayer.add(animation2, forKey: key2)
  }
  
  private func updateLayer() {
    shadowLayer?.cornerRadius = configuration_.cornerRadius
    //Logger.log("shadow layer \(shadowLayer?.fillColor)")
    shadowLayer?.fillColor = isEnabled ? configuration_.backgroundColor : configuration_.disabledBackgroundColor

    shadowLayer?.shadowColor = configuration_.shadowColor
    shadowLayer?.shadowOffset = CGSize(width: 0, height: 0)
    shadowLayer?.shadowOpacity = configuration_.shadowOpacity
    shadowLayer?.shadowRadius = configuration_.basicShadowRadius
  }
  
  private func makeLayer() {
    if shadowLayer == nil {
      shadowLayer = CAShapeLayer()
      updateLayer()

      layer.insertSublayer(shadowLayer, at: 0)
    }
  }
  
  private func updateLayerPath() {
    shadowLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: configuration_.cornerRadius).cgPath
    shadowLayer?.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: configuration_.cornerRadius).cgPath
  }
  
  func setConfiguration(configuration: CustomUIButtonConfiguration) {
    self.configuration_ = configuration
    self.updateLayer()
    self.updateLayerPath()
    self.layoutIfNeeded()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    makeLayer()
    updateLayerPath()
  }
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    Logger.log(#function)
    self.animateIn()
    UIView.animate(withDuration: 0.3) {
      self.transform = self.configuration_.buttonTransform
    }
    
    super.touchesBegan(touches, with: event)
  }
    
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    Logger.log(#function)
    self.animateOut()
    UIView.animate(withDuration: 0.3) {
      self.transform = .identity
    }
    super.touchesCancelled(touches, with: event)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    Logger.log(#function)
    self.animateOut()
    UIView.animate(withDuration: 0.3) {
      self.transform = .identity
    }
    super.touchesEnded(touches, with: event)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    Logger.log("Button type \(buttonType == .custom)")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
