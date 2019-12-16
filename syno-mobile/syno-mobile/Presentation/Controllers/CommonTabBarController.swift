//
//  CommonTabBarController.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class CommonTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let presentationAssembly: IPresentationAssembly
    
    init(presentationAssembly: IPresentationAssembly) {
        self.presentationAssembly = presentationAssembly
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let separatorView : UIView = {
        let v = UIView()
        
        v.backgroundColor = .lightGray
        v.alpha = 0.3
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setUpViewControllers()
        
        tabBar.addSubview(separatorView)
        separatorView.anchor(top: tabBar.topAnchor, left: tabBar.leftAnchor, bottom: nil, right: tabBar.rightAnchor, paddingTop: 0, paddingLeft: 1, paddingBottom: 0, paddingRight: 1, width: 0, height: 1)
        
        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }

    func setUpViewControllers() {
        let dictsController = templateNavController(unselectedImage: #imageLiteral(resourceName: "open-book"), selectedImage: #imageLiteral(resourceName: "open-book"), rootViewController: self.presentationAssembly.dictsViewController())
        
        let testAndLearnViewController = templateNavController(unselectedImage: #imageLiteral(resourceName: "shopping-list"), selectedImage: #imageLiteral(resourceName: "open-book"), rootViewController: self.presentationAssembly.testAndLearnViewController())
        
        self.viewControllers = [dictsController, testAndLearnViewController]
        self.selectedIndex = 0
    }

    fileprivate func templateNavController(unselectedImage : UIImage, selectedImage : UIImage?, rootViewController : UIViewController = UIViewController()) -> UINavigationController {
        let Controller = rootViewController
        let NavController = UINavigationController(rootViewController: Controller)
        NavController.tabBarItem.image = unselectedImage
        NavController.tabBarItem.selectedImage = selectedImage
        return NavController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
