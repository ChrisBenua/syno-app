import Foundation
import UIKit

/// Protocol for `HomeControllerMenuDataProvider` event handling
protocol IHomeControllerDataProviderDelegate: UIViewController {
    /// pushes new view controller on navigation controller
    func showController(controller: UIViewController)
    
    /// Shows process view with given text
    func showProcessView(text: String)
    
    /// Dismisses process view
    func dismissProcessView()
}

protocol IExtendedHomeControllerMenuItem {
    /// Icon for action
    var icon: UIImage? { get }
    /// Text for action
    var text: String? { get }
    /// Action
    var handler: (() -> ())? { get }
}

class ExtendedHomeControllerMenuItem: IExtendedHomeControllerMenuItem {
    var icon: UIImage?
    
    var text: String?
    
    var handler: (() -> ())?
    
    /**
     Create new `ExtendedHomeControllerMenuItem`
     - Parameter icon: Icon for action
     - Parameter text: Text for action
     - Parameter handler: action
     */
    init(icon: UIImage?, text: String?, handler: (() -> ())? = nil) {
        self.icon = icon
        self.text = text
        self.handler = handler
    }
}

/// Defines needed functions for inner logic of `HomeViewController`
protocol IHomeControllerMenuDataProvider {
    func onSignInAction()
    func onUploadDataToServer()
    func onDownloadDataFromServer()
    var delegate: IHomeControllerDataProviderDelegate? { get set }
    func userEmail() -> String
}

class HomeControllerMenuDataProvider: NSObject, IHomeControllerMenuDataProvider {
    /// Event handler
    weak var delegate: IHomeControllerDataProviderDelegate?
    
    /// Assembly for creating controller
    private var presAssembly: IPresentationAssembly
    
    /// Service responsible for fetching data from server
    private var dictControllerModel: IDictControllerModel
    
    /// Service for accessing `DbAppUser` CoreData instances
    private var currentUserManager: IAppUserStorageManager
    
    /// Service for creating copy on server
    private var updateService: IUpdateRequestService
        
    /**
     Creates new `HomeControllerMenuDataProvider`
     - Parameter presAssembly:Assembly for creating controller
     - Parameter dictControllerModel:Service responsible for fetching data from server
     - Parameter currentUserManager: Service for accessing `DbAppUser` CoreData instances
     - Parameter updateService: Service for creating copy on server
     */
    init(presAssembly: IPresentationAssembly, dictControllerModel: IDictControllerModel, currentUserManager: IAppUserStorageManager, updateService: IUpdateRequestService) {
        self.presAssembly = presAssembly
        self.dictControllerModel = dictControllerModel
        self.currentUserManager = currentUserManager
        self.updateService = updateService
        super.init()
    }
    
    /// Gets current user email
    func userEmail() -> String {
        return currentUserManager.getCurrentUserEmail()!
    }
    
    /// Hanles sign in action
    func onSignInAction() {
        let controller = self.presAssembly.loginFromHomeViewController()
        self.delegate?.showController(controller: controller)
    }
    
    /// Handler uploading dictionaries to server
    func onUploadDataToServer() {
        if currentUserManager.getCurrentUserEmail() == "Guest" {
            let alertController = UIAlertController.okAlertController(title: "Вы не зарегистрированы", message: "Войдите и попробуйте снова")
            self.delegate?.present(alertController, animated: true, completion: nil)
        } else {
            self.delegate?.showProcessView(text: "Загрузка...")
            self.updateService.sendRequest { (result) in
                DispatchQueue.main.async {
                    self.delegate?.dismissProcessView()
                    switch result {
                    case .error(let str):
                        let alertController = UIAlertController.okAlertController(title: "Произошла ошибка", message: str)
                        self.delegate?.present(alertController, animated: true, completion: nil)
                    case .success(_):
                        break
                    }
                }
            }
        }
    }
    
    /// Handles downloading user's dictionaries from server
    func onDownloadDataFromServer() {
        if currentUserManager.getCurrentUserEmail() == "Guest" {
            let alertController = UIAlertController.okAlertController(title: "Вы не зарегистрированы", message: "Войдите и попробуйте снова")
            self.delegate?.present(alertController, animated: true, completion: nil)
        } else {
            self.delegate?.showProcessView(text: "Загрузка...")
            self.dictControllerModel.initialFetch(completion: { (success) in
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                        self.delegate?.dismissProcessView()
                        if !success {
                            let alertController = UIAlertController.okAlertController(title: "Произошла ошибка", message: "Проверьте ваше соединение")
                            self.delegate?.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
}
