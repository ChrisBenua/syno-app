import Foundation
import UIKit

/// Default view with shadow view behind main view
class BaseShadowView: UIView {
    
    override var bounds: CGRect {
        didSet {
            layerSetUp()
        }
    }
    
    var containerViewBackgroundColor: UIColor?
    
    var cornerRadius: CGFloat?
    
    var shadowRadius: CGFloat?
    
    lazy var containerView : UIView = {
        let iv = UIView()
        iv.clipsToBounds = true
        return iv
    }()
    /// View with shadows, below all views in cells
    lazy var shadowView : ShadowView = {
        let view = ShadowView()
        return view
    }()
    
    
    ///Configure layer of mainCellView
    func layerSetUp() {
        shadowView.shadowRadius = shadowRadius ?? 2
        containerView.layer.cornerRadius = cornerRadius ?? 8
        containerView.backgroundColor = self.containerViewBackgroundColor ?? .gray
        shadowView.cornerRadius = self.cornerRadius
    }
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(shadowView)
        
        shadowView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
        
        self.addSubview(containerView)
        layerSetUp()
        containerView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
