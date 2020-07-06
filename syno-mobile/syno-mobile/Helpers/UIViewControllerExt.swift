//
//  UIViewControllerExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let items = navigationBar.items, viewControllers.count < items.count {
            return true
        }

        topViewController?.navigationShouldPopOnBack(completion: { isAllowPop in
            if isAllowPop {
                DispatchQueue.main.async {
                    self.popViewController(animated: true)
                }
            }
        })

        return false
    }
}

extension UIViewController {
    @objc func navigationShouldPopOnBack(completion: @escaping (Bool) -> ()) {
        completion(true)
    }
}
