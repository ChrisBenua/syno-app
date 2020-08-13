//
//  UIViewControllerExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class MyNavigationController: UINavigationController, UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
        Logger.log(#function)
    }
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
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
        return true
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        Logger.log("Popped")
    }
}


public extension UIViewController {
    @objc public func navigationShouldPopOnBack(completion: @escaping (Bool) -> ()) {
        completion(true)
    }
}
