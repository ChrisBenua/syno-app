import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? {
        didSet {
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .light
            } else {
            }
        }
    }
    
    var rootAssembly: RootAssembly!
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //launchOptions[.]
        rootAssembly = RootAssembly()
        Logger.log(#function)
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = .headerMainColor
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        
        let controller = rootAssembly.presentationAssembly.startController()
        window?.rootViewController = controller
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Logger.log(#function)
        let sendingAppId = options[.sourceApplication]
        Logger.log("Source application = \(sendingAppId ?? "Unknown")")
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let action = components.path,
              let params = components.queryItems else {
            Logger.log("Invalid URL or album path missing")
            return false
        }
        
        if let dictShareUuid = params.first(where: { $0.name == "uuid" })?.value, action == "share" {
            Logger.log("action: \(action), uuid: \(dictShareUuid)")
            
            let controller = rootAssembly.presentationAssembly.addShareController(uuid: dictShareUuid)
            if let tabBarController = window?.rootViewController as? CommonTabBarController, let current = tabBarController.selectedViewController {
                (current as? UINavigationController)?.pushViewController(controller, animated: true)
            } else {
                if let loginController = window?.rootViewController as? LoginViewController {
                    let alertController = UIAlertController.okAlertController(title: "Ошибка", message: "Чтобы скачать Словарь необходимо войти в учетную запись")
                    //alertController.addAction(.okAction)
                    loginController.present(alertController, animated: true)
                }
            }
            return true
        } else {
            Logger.log("Missing dictshareuuid")
            return false
        }
    }
}

