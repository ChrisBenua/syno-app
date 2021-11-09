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

        rootAssembly.coreAssembly.updateWidgetDataTask.registerUpdateWidgetDataTask()
        rootAssembly.coreAssembly.updateWidgetDataTask.scheduleUpdateWidgetData()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL else { return false }
      return handleDeeplink(url: url)
    }
    
    private func showShareController(uuid: String) {
        let controller = rootAssembly.presentationAssembly.addShareController(uuid: uuid)
        if let current = getCurrentNavigationController() {
            current.pushViewController(controller, animated: true)
        } else {
            if let loginController = window?.rootViewController as? LoginViewController {
                let alertController = UIAlertController.okAlertController(title: "Ошибка", message: "Чтобы скачать Словарь необходимо войти в учетную запись")
                loginController.present(alertController, animated: true)
            }
        }
    }

    private func showSpecificCardController(dictId: String, cardId: String) {
      if let controller = getCurrentNavigationController() {
        guard let dict = try? rootAssembly.coreAssembly.storageManager.stack.mainContext.fetch(DbUserDictionary.requestByPin(pin: dictId)).first else { return }
        guard let card = dict.getCards().first(where: { $0.pin == cardId }) else { return }
        let dictController = rootAssembly.presentationAssembly.cardsViewController(sourceDict: dict)
        let cardController = rootAssembly.presentationAssembly.translationsViewController(sourceCard: card)
        controller.pushViewController(dictController, animated: false)
        controller.pushViewController(cardController, animated: true)
      }
    }

    private func getCurrentNavigationController() -> UINavigationController? {
      if let tabBarController = window?.rootViewController as? CommonTabBarController, let current = tabBarController.selectedViewController {
        return current as? UINavigationController
      } else {
        return nil
      }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Logger.log(#function)
        let sendingAppId = options[.sourceApplication]
        Logger.log("Source application = \(sendingAppId ?? "Unknown")")
        
        return handleDeeplink(url: url)
    }

    private func handleDeeplink(url: URL) -> Bool {
      guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
          Logger.log("Invalid URL")
          return false
      }
      let action = urlComponents.path
      let components = url.pathComponents

      if action.starts(with: "/share"), let dictShareUuid = urlComponents.path.split(separator: "/").last {
          showShareController(uuid: String(dictShareUuid))
          return true
      } else if components.count >= 2, components[1] == "widgetOpenCard",
                let params = urlComponents.queryItems,
                let dictId = params.first(where: { $0.name == "dictId" })?.value,
                let cardId = params.first(where: { $0.name == "cardId" })?.value
      {
          showSpecificCardController(dictId: dictId, cardId: cardId)
          return true
      }
      else {
          Logger.log("Missing dictshareuuid")
          return false
      }
  }
}

