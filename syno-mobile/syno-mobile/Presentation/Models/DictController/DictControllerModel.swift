import Foundation

/// Service for fetching dicts from server
protocol IDictControllerModel: ITransferGuestDictsToNewAccountDelegate {
    /// Fetches all user's dictionaries from server
    /// - Parameter completion: completion callback
    func initialFetch(completion: ((Bool) -> ())?)
    
    func shouldAskToCopyGuestDicts() -> Bool
    
    func copyGuestDictsToCurrentUser()
    
    var delegate: ITransferGuestDictsToNewAccountDelegate? {get set}
}

class DictControllerModel: IDictControllerModel {
    
    func onSuccess() {
        self.delegate?.onSuccess()
    }
    
    func onFailure(err: String) {
        self.delegate?.onFailure(err: "Произошла ошибка")
    }
    
    weak var delegate: ITransferGuestDictsToNewAccountDelegate?
    
    /// Service for updating/creating/deleting dictionaries
    private let userDictsFetchService: IUserDictionaryFetchService
    /// Service for sending requests
    private let requestSender: IRequestSender
    /// Service for setting/getting data from `UserDefaults`
    private let userDefManager: IUserDefaultsManager
    /// Service for fetching/updating information about current user
    private let appUserManager: IStorageCoordinator
    
    private var transferService: ITransferGuestDictsToNewAccount
    
    /**
     Creates new `DictControllerModel`
     - Parameter userDictsFetchService: Service for updating/creating/deleting dictionaries
     - Parameter sender:Service for sending requests
     - Parameter userDefManager:Service for setting/getting data from `UserDefaults`
     - Parameter appUserManager: Service for fetching/updating information about current user
     */
    init(userDictsFetchService: IUserDictionaryFetchService, sender: IRequestSender, userDefManager: IUserDefaultsManager, appUserManager: IStorageCoordinator, transferService: ITransferGuestDictsToNewAccount) {
        self.userDictsFetchService = userDictsFetchService
        self.requestSender = sender
        self.userDefManager = userDefManager
        self.appUserManager = appUserManager
        self.transferService = transferService
        self.transferService.delegate = self
    }
    
    func shouldAskToCopyGuestDicts() -> Bool {
        return transferService.needToTransferDictsFromGuest()
    }
    
    func copyGuestDictsToCurrentUser() {
        transferService.delegate = self
        transferService.transferToUser(newUserEmail: self.userDefManager.getEmail()!)
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
