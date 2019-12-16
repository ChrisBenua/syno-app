//
//  BaseShadowView.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 13.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

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
        shadowView.shadowRadius = 2
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
