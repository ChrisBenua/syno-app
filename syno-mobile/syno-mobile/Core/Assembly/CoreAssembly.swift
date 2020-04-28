import Foundation

protocol ICoreAssembly {
    var requestSender: IRequestSender { get }

    var userDefaultsManager: IUserDefaultsManager { get }
    
    var storageManager: IStorageCoordinator { get }
    
    var phonemesManager: IPhonemesManager { get }
}

class CoreAssembly: ICoreAssembly {
    let requestSender: IRequestSender = DefaultRequestSender()
    let userDefaultsManager: IUserDefaultsManager = UserDefaultsManager()
    let storageManager: IStorageCoordinator = StorageManager()
    let phonemesManager: IPhonemesManager
    
    init() {
        self.phonemesManager = PhonemesManager()
        phonemesManager.initialize()
    }
}
