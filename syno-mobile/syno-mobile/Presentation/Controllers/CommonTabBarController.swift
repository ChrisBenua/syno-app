import Foundation
import UIKit

/// Main tab bar controller with `DictionariesViewController`, `TestAndLearnController` and `HomeController`
class CommonTabBarController: UITabBarController, UITabBarControllerDelegate {
    /// Assembly for creating view controllers
    private let presentationAssembly: IPresentationAssembly
    
    /**
     Creates new `CommonTabBarController`
     - Parameter presentationAssembly: Assembly for creating view controllers
     */
    init(presentationAssembly: IPresentationAssembly) {
        self.presentationAssembly = presentationAssembly
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// View above tabBar to separate view and tabBar
    let separatorView : UIView = {
        let v = UIView()
        
        v.backgroundColor = .lightGray
        v.alpha = 0.3
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = .headerMainColor
        setUpViewControllers()
        
        tabBar.addSubview(separatorView)
        separatorView.anchor(top: tabBar.topAnchor, left: tabBar.leftAnchor, bottom: nil, right: tabBar.rightAnchor, paddingTop: 0, paddingLeft: 1, paddingBottom: 0, paddingRight: 1, width: 0, height: 1)
        
        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    /// Fills tab bar view controllers
    func setUpViewControllers() {
        let dictsController = templateNavController(unselectedImage: #imageLiteral(resourceName: "open-book"), selectedImage: #imageLiteral(resourceName: "open-book"), rootViewController: self.presentationAssembly.dictsViewController())
        
        let testAndLearnViewController = templateNavController(unselectedImage: #imageLiteral(resourceName: "shopping-list"), selectedImage: #imageLiteral(resourceName: "shopping-list"), rootViewController: self.presentationAssembly.testAndLearnViewController())
        
        let homeController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"), rootViewController: presentationAssembly.homeController())
        
        self.viewControllers = [dictsController, testAndLearnViewController, homeController]
        self.selectedIndex = 0
    }

    /**
     Wraps ViewController in `UINavigationController`
     - Parameter unselectedImage: tabbar image for unselected state
     - Parameter selectedImage: tabBar image for selected state
     - Parameter rootViewController: viewController to be wrapped
     */
    fileprivate func templateNavController(unselectedImage : UIImage, selectedImage : UIImage?, rootViewController : UIViewController = UIViewController()) -> UINavigationController {
        let Controller = rootViewController
        let NavController = UINavigationController(rootViewController: Controller)
        NavController.tabBarItem.image = unselectedImage
        NavController.tabBarItem.selectedImage = selectedImage
        return NavController
    }
}
