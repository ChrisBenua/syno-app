import Foundation

/// Protocol with defing logic updating `DbTranslation`s
protocol ITranslationFetchService {
    /**
     Updates given translations
     - Parameter translations: Translations dtos -- after this function linked `DbTranslation`s should match `translations`
     - Parameter doSave: Should save changes
     - Parameter sourceCard: Card which translations should be updated
     - Parameter completion: Completion callback
     */
    func updateTranslations(translations: [GetTranslationDto], doSave: Bool, sourceCard: DbUserCard?, completion: (()->Void)?) -> Void
}

/// Protocol with updating `DbUserCard`s logic
protocol IUserCardsFetchService {
    /**
     Updates given cards
     - Parameter cards: Cards dtos -- after this functions linked `DbUserCard`s should match `cards`
     - Parameter doSave: Should save changes
     - Parameter sourceDict: Dictionary which cards should be updated
     - Parameter completion: Completion callback
     */
    func updateCards(cards: [GetCardResponseDto], doSave: Bool, sourceDict: DbUserDictionary?, completion: (()->Void)?)
}

/// Protocol with updating `DbUserDictionary`s logic
protocol IUserDictionaryFetchService {
    /**
     Updates given Dictionaries
     - Parameter dicts: Dicts dtos -- after this function linked `DbUserDictionary`s should match `dicts`
     - Parameter owner: User, whos dictionaries will be updated
     - Parameter shouldDelete: should Delete Dictionaries that not in `dicts`
     - Parameter completion: completion callback
     */
    func updateDicts(dicts: [GetDictionaryResponseDto], owner: DbAppUser, shouldDelete: Bool, completion: (()->Void)?)
}

class DbTranslationFetchService: ITranslationFetchService {

    private var storageManager: IStorageCoordinator
    private let innerQueue: DispatchQueue
    
    /**
     Creates new `DbTranslationFetchService`
     - Parameter innerQueue: queue for submitting asynchronious tasks
     - Parameter storageManager: instance for handling saving/modification of `DbUserDictionary`, `DbUserCard` and `DbUserTranslations`
     */
    init(innerQueue: DispatchQueue, storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
        self.innerQueue = innerQueue
    }
    
    func updateTranslations(translations: [GetTranslationDto], doSave: Bool = false, sourceCard: DbUserCard?, completion: (()->Void)?) {
        self.storageManager.stack.saveContext.performAndWait {
            let allTranslations: [DbTranslation] = sourceCard?.translations?.toArray() ?? []
            let existingPins = Set(translations.map { (el) -> String in
                el.pin
            })
            
            var updatedPins = Set<String>()
            var toRemove: [DbTranslation] = []
            let dispatchGroup = DispatchGroup()
        
            for dbTranslation in allTranslations {
                if existingPins.contains(dbTranslation.pin!) {
                    updatedPins.insert(dbTranslation.pin!)
                    
                    let updateTransDto = translations.filter { (el) -> Bool in
                        el.pin == dbTranslation.pin
                    }.first
                    
                    if let updateTransDto = updateTransDto {
                        dbTranslation.comment = updateTransDto.comment
                        dbTranslation.transcription = updateTransDto.transcription
                        dbTranslation.translation = updateTransDto.translation
                        dbTranslation.usageSample = updateTransDto.usageSample
                        dbTranslation.timeModified = updateTransDto.timeModified
                    }
                    
                } else {
                    toRemove.append(dbTranslation)
                }
            }
            
            for el in toRemove {
                sourceCard?.removeFromTranslations(el)
                self.storageManager.stack.saveContext.delete(el)
            }
            
            for updateTranslation in translations {
                if !updatedPins.contains(updateTranslation.pin) {
                    self.innerQueue.async(group: dispatchGroup) {
                        self.storageManager.createTranslation(sourceCard: sourceCard, usageSample: updateTranslation.usageSample, translation: updateTranslation.translation, transcription: updateTranslation.transcription, comment: updateTranslation.comment, serverId: updateTranslation.id, timeCreated: updateTranslation.timeCreated, timeModified: updateTranslation.timeModified, pin: updateTranslation.pin, completion: { (trans) -> Void in
                        })
                    }
                }
            }
            dispatchGroup.notify(queue: self.innerQueue) {
                if doSave {
                    self.storageManager.stack.performSave(with: self.storageManager.stack.saveContext, completion: completion)
                } else {
                    completion?()
                }
            }
        }
    }
}
