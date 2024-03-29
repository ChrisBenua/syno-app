import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = .headerMainColor
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        
        let controller = RootAssembly().presentationAssembly.startController()
        window?.rootViewController = controller
        
        return true
    }
}

