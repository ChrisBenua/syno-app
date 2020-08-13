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
    
    var containerViewInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    var cornerRadius: CGFloat? {
        didSet {
            if let cr = self.cornerRadius {
                containerView.layer.cornerRadius = cr
            }
        }
    }
    
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
    
    init(containerViewInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)) {
        super.init(frame: .zero)
        self.containerViewInsets = containerViewInsets
        
        self.addSubview(shadowView)
        
        shadowView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: containerViewInsets.top, paddingLeft: containerViewInsets.left, paddingBottom: containerViewInsets.bottom, paddingRight: containerViewInsets.right, width: 0, height: 0)
        
        self.addSubview(containerView)
        layerSetUp()
        containerView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: containerViewInsets.top, paddingLeft: containerViewInsets.left, paddingBottom: containerViewInsets.bottom, paddingRight: containerViewInsets.right, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
