import Foundation
import UIKit

extension UIAlertAction {
    /// Default ok action
    static var okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
}

extension UIAlertController {
    /// Alert Controller with dummy ok action
    static func okAlertController(title: String, message: String? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction.okAction)
        return controller
    }
}
