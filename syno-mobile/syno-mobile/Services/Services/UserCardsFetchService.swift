import Foundation
import CoreData

class UserCardsFetchService: IUserCardsFetchService {
    
    private let innerQueue: DispatchQueue
    private var storageManager: IStorageCoordinator
    
    private var translationsFetchService: ITranslationFetchService
        
    /**
     Creates new `UserCardsFetchService`
     - Parameter innerQueue: Queue for submitting async tasks
     - Parameter storageManager: instance for handling CRUD operations
     - Parameter translationsFetchService: instance for saving/editing `DbTranslation`s
     */
    init(innerQueue: DispatchQueue, storageManager: IStorageCoordinator, translationsFetchService: ITranslationFetchService) {
        self.storageManager = storageManager
        self.innerQueue = innerQueue
        self.translationsFetchService = translationsFetchService
    }
    
    func updateCards(cards: [GetCardResponseDto], doSave: Bool, sourceDict: DbUserDictionary?, completion: (()->Void)?) {
        self.storageManager.stack.saveContext.performAndWait {
            let allDictCards: [DbUserCard] = sourceDict?.userCards?.toArray() ?? []
            let existingCardPins = Set(cards.map { (el) -> String in
                return el.pin
            })
            var updatedPins = Set<String>()
            var toRemove: [DbUserCard] = []
            let dispatchGroup = DispatchGroup()
        
            for userCard in allDictCards {
                if existingCardPins.contains(userCard.pin!) {
                    updatedPins.insert(userCard.pin!)
                    
                    let updateCardDto = cards.filter { (el) -> Bool in
                        el.pin == userCard.pin
                    }.first
                    
                    if let updateCardDto = updateCardDto {
                        userCard.translatedWord = updateCardDto.translatedWord
                        userCard.timeModified = updateCardDto.timeModified
                        
                        dispatchGroup.enter()
                        self.innerQueue.async {
                            self.translationsFetchService.updateTranslations(translations: updateCardDto.translations, doSave: false, sourceCard: userCard, completion: {
                                dispatchGroup.leave()
                            })
                        }
                    }
                } else {
                    toRemove.append(userCard)
                }
            }
            
            for el in toRemove {
                sourceDict?.removeFromUserCards(el)
                self.storageManager.stack.saveContext.delete(el)
            }
            
            for updateUserCard in cards {
                if !updatedPins.contains(updateUserCard.pin) {
                    dispatchGroup.enter()
                    self.innerQueue.async {
                    self.storageManager.createUserCard(sourceDict: sourceDict, translatedWord: updateUserCard.translatedWord, timeCreated: updateUserCard.timeCreated, timeModified: updateUserCard.timeModified, serverId: updateUserCard.id, translation: nil, pin: updateUserCard.pin) { (newCard) in
                        self.translationsFetchService.updateTranslations(translations: updateUserCard.translations, doSave: true, sourceCard: newCard, completion: {
                            dispatchGroup.leave()
                        })
                    }
                    }
                }
            }
            self.innerQueue.async {
                dispatchGroup.wait()
                if doSave {
                    self.storageManager.stack.performSave(with: self.storageManager.stack.saveContext, completion: completion)
                } else {
                    completion?()
                }
            }
        }
    }
}
