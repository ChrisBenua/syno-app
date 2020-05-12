import Foundation
import CoreData
import UIKit

/// Protocol for creating and getting dictionary shares
protocol IDictShareService {
    /**
     Creates share
     - Parameter dictObjectId: Id of dictionary to be shared
     - Parameter completion: completion callback
     */
    func createShare(dictObjectID: NSManagedObjectID, completion: ((Result<String>) -> ())?)
    
    /**
      Gets share and copies dictionary to current user
     - Parameter shareUUID: share's id
     - Parameter completion: completion callback
     */
    func getShare(shareUUID: String, completion: ((Result<String>) -> ())?)
}

class DictShareService: IDictShareService {
    
    private var userDefManager: IUserDefaultsManager
    
    private var requestSender: IRequestSender
    
    private var storageManager: IStorageCoordinator
    
    private var dictsFetchService: IUserDictionaryFetchService
    
    func createShare(dictObjectID: NSManagedObjectID, completion: ((Result<String>) -> ())?) {
        if (storageManager.getCurrentUserEmail() != "Guest") {
            let dictPin = (self.storageManager.stack.mainContext.object(with: dictObjectID) as! DbUserDictionary).pin!
            let requestConfig = RequestFactory.BackendRequests.createShare(dto: NewDictShare(shareDictPin: dictPin), userDefManager: userDefManager)
            self.requestSender.send(requestConfig: requestConfig) { (result) in
                switch result {
                case .success(let messageDto):
                    UIPasteboard.general.string = messageDto.message
                    completion?(.success("Код: \(messageDto.message) скопирован"))
                case .error(let err):
                    completion?(.error(err))
                }
            }
        } else {
            completion?(.error("Вы не вошли в аккаунт, поэтому пока не можете делиться словарями"))
        }
    }
    
    func getShare(shareUUID: String, completion: ((Result<String>) -> ())?) {
        if (storageManager.getCurrentUserEmail() != "Guest") {
            let requestConfig = RequestFactory.BackendRequests.getShare(dto: GetShareRequestConfig(shareUUID: shareUUID), userDefManager: userDefManager)
            self.requestSender.send(requestConfig: requestConfig) { (result) in
                switch result {
                case .success(let dictResponseDto):
                    self.createSharedDict(dictResponseDto: dictResponseDto, completion: {
                        completion?(.success("Словарь сохранен!"))
                    })
                case .error(let err):
                    completion?(.error(err))
                }
            }
        } else {
            completion?(.error("Вы не вошли в аккаунт, поэтому пока вы не можете копировать чужие словари"))
        }
    }
    
    /**
     Copies dictionary from `dictResponseDto` to current user
     - Parameter dictResponseDto: shared dictionary dto
     - Parameter completion: completion callback
     */
    private func createSharedDict(dictResponseDto: GetDictionaryResponseDto, completion: (() -> ())?) {
        dictsFetchService.updateDicts(dicts: [dictResponseDto], owner: self.storageManager.getCurrentAppUser()!, shouldDelete: false) {
            completion?()
        }
    }
    
    /**
     Creates new `DictShareService` instance
     - Parameter userDefManager: instance responsible for saving/getting items from UserDefaults
     - Parameter requestSender: instance responsible for sending web requests
     - Parameter storageManager: instance responsible for getting instances of DbAppUser
     - Parameter dictsFetchService: instance responsible for updating DbUserDictionaries
     */
    init(userDefManager: IUserDefaultsManager, requestSender: IRequestSender, storageManager: IStorageCoordinator, dictsFetchService: IUserDictionaryFetchService) {
        self.userDefManager = userDefManager
        self.requestSender = requestSender
        self.storageManager = storageManager
        self.dictsFetchService = dictsFetchService
    }
    
}
