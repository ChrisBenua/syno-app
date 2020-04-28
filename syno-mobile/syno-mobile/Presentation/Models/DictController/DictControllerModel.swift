import Foundation

protocol IDictControllerModel {
    func initialFetch(completion: ((Bool) -> ())?)
}

class DictControllerModel: IDictControllerModel {
    private let userDictsFetchService: IUserDictionaryFetchService
    private let requestSender: IRequestSender
    private let userDefManager: IUserDefaultsManager
    private let appUserManager: IStorageCoordinator
    
    init(userDictsFetchService: IUserDictionaryFetchService, sender: IRequestSender, userDefManager: IUserDefaultsManager, appUserManager: IStorageCoordinator) {
        self.userDictsFetchService = userDictsFetchService
        self.requestSender = sender
        self.userDefManager = userDefManager
        self.appUserManager = appUserManager
    }
    
    func initialFetch(completion: ((Bool) -> ())? = nil) {
        if userDefManager.getNetworkMode() {
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
        } else {
            completion?(false)
        }
    }
}
