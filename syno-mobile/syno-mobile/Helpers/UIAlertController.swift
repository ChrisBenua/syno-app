//
// Created by Ирина Улитина on 26.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertAction {
    static var okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
}

extension UIAlertController {
    static func okAlertController(title: String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        controller.addAction(UIAlertAction.okAction)
        return controller
    }
}