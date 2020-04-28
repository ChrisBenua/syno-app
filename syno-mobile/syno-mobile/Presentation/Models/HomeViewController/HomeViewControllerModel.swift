import Foundation
import UIKit

protocol IHomeControllerMenuItem {
    var icon: UIImage? { get }
    var text: String? { get }
}

protocol IHomeControllerDataProviderDelegate: UIViewController {
    func showController(controller: UIViewController)
    
    func showProcessView(text: String)
    
    func dismissProcessView()
}

protocol IExtendedHomeControllerMenuItem: IHomeControllerMenuItem {
    var handler: (() -> ())? { get }
}

class ExtendedHomeControllerMenuItem: IExtendedHomeControllerMenuItem {
    var icon: UIImage?
    
    var text: String?
    
    var handler: (() -> ())?
    
    init(icon: UIImage?, text: String?, handler: (() -> ())? = nil) {
        self.icon = icon
        self.text = text
        self.handler = handler
    }
}

protocol IHomeControllerMenuDataProvider {
    func onSignInAction()
    func onUploadDataToServer()
    func onDownloadDataFromServer()
    var delegate: IHomeControllerDataProviderDelegate? { get set }
    func userEmail() -> String
}

class HomeControllerMenuDataProvider: NSObject, IHomeControllerMenuDataProvider {    
    weak var delegate: IHomeControllerDataProviderDelegate?
    
    private var presAssembly: IPresentationAssembly
    
    private var dictControllerModel: IDictControllerModel
    
    private var currentUserManager: IAppUserStorageManager
    
    private var updateService: IUpdateRequestService
        
    init(presAssembly: IPresentationAssembly, dictControllerModel: IDictControllerModel, currentUserManager: IAppUserStorageManager, updateService: IUpdateRequestService) {
        self.presAssembly = presAssembly
        self.dictControllerModel = dictControllerModel
        self.currentUserManager = currentUserManager
        self.updateService = updateService
        super.init()
    }
    
    func userEmail() -> String {
        return currentUserManager.getCurrentUserEmail()!
    }
    
    func onSignInAction() {
        let controller = self.presAssembly.loginFromHomeViewController()
        self.delegate?.showController(controller: controller)
    }
    
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
