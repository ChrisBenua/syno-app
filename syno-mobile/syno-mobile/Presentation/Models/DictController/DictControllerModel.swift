import Foundation

/// Service for fetching dicts from server
protocol IDictControllerModel {
    /// Fetches all user's dictionaries from server
    /// - Parameter completion: completion callback
    func initialFetch(completion: ((Bool) -> ())?)
}

class DictControllerModel: IDictControllerModel {
    /// Service for updating/creating/deleting dictionaries
    private let userDictsFetchService: IUserDictionaryFetchService
    /// Service for sending requests
    private let requestSender: IRequestSender
    /// Service for setting/getting data from `UserDefaults`
    private let userDefManager: IUserDefaultsManager
    /// Service for fetching/updating information about current user
    private let appUserManager: IStorageCoordinator
    
    /**
     Creates new `DictControllerModel`
     - Parameter userDictsFetchService: Service for updating/creating/deleting dictionaries
     - Parameter sender:Service for sending requests
     - Parameter userDefManager:Service for setting/getting data from `UserDefaults`
     - Parameter appUserManager: Service for fetching/updating information about current user
     */
    init(userDictsFetchService: IUserDictionaryFetchService, sender: IRequestSender, userDefManager: IUserDefaultsManager, appUserManager: IStorageCoordinator) {
        self.userDictsFetchService = userDictsFetchService
        self.requestSender = sender
        self.userDefManager = userDefManager
        self.appUserManager = appUserManager
    }
    
    func initialFetch(completion: ((Bool) -> ())? = nil) {
        self.requestSender.send(requestConfig: RequestFactory.BackendRequests.allDictsRequest(userDefaultsManager: self.userDefManager)) { (result) in
                switch result {
                case .success(let dtos):
                    let user = self.appUserManager.getCurrentAppUser()!
                    self.userDictsFetchService.updateDicts(dicts: dtos, owner: user, shouldDelete: true, completion: {
                        completion?(true)
                    })
                case .error(let str):
                    Logger.log("Error while doing init fetch in dicts controller: \(#function)")
                    Logger.log("Error: \(str)\n")
                    completion?(false)
                }
            }
    }
}
