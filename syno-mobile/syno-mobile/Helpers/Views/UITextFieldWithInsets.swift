//
// Created by Ирина Улитина on 23.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class UITextFieldWithInsets: UITextField {

    private var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.insets)
    }

    override var intrinsicContentSize: CGSize {
        let superSz = super.intrinsicContentSize
        return CGSize(width: superSz.width + insets.left + insets.right, height: superSz.height + insets.top + insets.bottom)
    }

    init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}