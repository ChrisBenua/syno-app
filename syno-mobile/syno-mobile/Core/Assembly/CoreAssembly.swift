import Foundation

/// Assembly protocol for creating core level services
protocol ICoreAssembly {
    /// Service for sending web requests
    var requestSender: IRequestSender { get }
    
    /// Service for interacting with `UserDefaults`
    var userDefaultsManager: IUserDefaultsManager { get }
    
    /// Service for accessing `CoreData`
    var storageManager: IStorageCoordinator { get }
    
    /// Service for generating transcriptions
    var phonemesManager: IPhonemesManager { get }
    
    var updateActionsExecutor: IUpdateActionsExecutor { get }

    var updateWidgetDataTask: UpdateWidgetDataTaskPerforming { get }
}

/// Assembly for creating core level services
class CoreAssembly: ICoreAssembly {
    let requestSender: IRequestSender = DefaultRequestSender()
    let userDefaultsManager: IUserDefaultsManager = UserDefaultsManager()
    let storageManager: IStorageCoordinator = StorageManager()
    let phonemesManager: IPhonemesManager
    let updateActionsExecutor: IUpdateActionsExecutor = UpdateActionsExecutor()
    lazy var updateWidgetDataTask: UpdateWidgetDataTaskPerforming = UpdateWidgetDataTask(storageManager: storageManager, widgetUserDefaults: WidgetUserDefaults())
    
    init() {
        self.phonemesManager = PhonemesManager()
        phonemesManager.initialize()
    }
}
