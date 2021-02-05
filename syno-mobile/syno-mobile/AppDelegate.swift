import UIKit
import AVFoundation

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
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch _ {
            Logger.log("Error in activation AVAudioSession")
        }
        
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
              return false
          }
        if let dictShareUuid = components.path.split(separator: "/").last {
            showShareController(uuid: String(dictShareUuid))
            return true
        }
        return false
    }
    
    private func showShareController(uuid: String) {
        let controller = rootAssembly.presentationAssembly.addShareController(uuid: uuid)
        if let tabBarController = window?.rootViewController as? CommonTabBarController, let current = tabBarController.selectedViewController {
            (current as? UINavigationController)?.pushViewController(controller, animated: true)
        } else {
            if let loginController = window?.rootViewController as? LoginViewController {
                let alertController = UIAlertController.okAlertController(title: "Ошибка", message: "Чтобы скачать Словарь необходимо войти в учетную запись")
                loginController.present(alertController, animated: true)
            }
        }
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
            showShareController(uuid: dictShareUuid)
            
            return true
        } else {
            Logger.log("Missing dictshareuuid")
            return false
        }
    }
}

