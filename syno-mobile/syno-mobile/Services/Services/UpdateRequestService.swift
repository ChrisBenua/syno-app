import Foundation

/// Protocol for creating copy on server
protocol IUpdateRequestService {
    /// Updates user's dictionaries on server
    func sendRequest(completion: ((Result<String>) -> ())?)
}

/// Class responsible for creating copy on server
class UpdateRequestService: IUpdateRequestService {
    private var storageManager: IStorageCoordinator
    private var sender: IRequestSender
    private var userDefManager: IUserDefaultsManager
    
    func sendRequest(completion: ((Result<String>) -> ())?) {
        DispatchQueue.global(qos: .background).async {
            let dto = self.prepareData()
            let request = RequestFactory.BackendRequests.updateDictsRequest(updateDictsDto: dto, userDefManager: self.userDefManager)
            
            self.sender.send(requestConfig: request) { (result) in
                switch result {
                case .success(let messageResponse):
                    completion?(.success(messageResponse.message))
                case .error(let error):
                    completion?(.error(error))
                }
            }
        }
        
    }
    
    func prepareData() -> UpdateRequestDto {
        let user = storageManager.getCurrentAppUser()
        var dicts: [DbUserDictionary] = []
        var dto: UpdateRequestDto!
        user?.managedObjectContext?.performAndWait {
            dicts = user?.dictionaries?.toArray() ?? []
            
            dto = UpdateRequestDto(existingDictPins: dicts.map({ (el) -> String in
                return el.pin!
            }), clientDicts: dicts.map({ (el) -> UpdateUserDictionaryDto in
                return UpdateUserDictionaryDto(pin: el.pin!, name: el.name ?? "", language: el.language ?? "", timeCreated: el.timeCreated, timeModified: el.timeModified,
                    userCards: el.getCards().map({ (card) -> UpdateUserCardDto in
                        return UpdateUserCardDto(pin: card.pin!, translatedWord: card.translatedWord ?? "", timeCreated: card.timeCreated, timeModified: card.timeModified, translations: card.getTranslations().map({ (trans) -> UpdateUserTranslationDto in
                            return UpdateUserTranslationDto(pin: trans.pin!, translation: trans.translation ?? "", comment: trans.comment ?? "", transcription: trans.transcription ?? "", usageSample: trans.usageSample ?? "", timeCreated: trans.timeCreated, timeModified: trans.timeModified)
                        }))
                    }))
            }))
        }
        
        return dto
    }
    
    /**
     Creates new `UpdateRequestService`
     - Parameter storageManager: instance responsible for operations with DbAppUser instances
     - Parameter sender: instance resposible for sending requests
     - Parameter userDefaultsManager: instance responsible for saving/getting items from User Defaults
     */
    init(storageManager: IStorageCoordinator, sender: IRequestSender, userDefaultsManager: IUserDefaultsManager) {
        self.storageManager = storageManager
        self.sender = sender
        self.userDefManager = userDefaultsManager
    }
}
