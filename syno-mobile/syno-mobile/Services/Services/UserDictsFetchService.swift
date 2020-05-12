import Foundation
import CoreData

/// Class responsible for updating user's dictionaries
class UserDictsFetchService: IUserDictionaryFetchService {
    
    private let innerQueue: DispatchQueue// = DispatchQueue(label: "UserDictsFetchService")
    
    private var storageManager: IStorageCoordinator
    
    private var cardsFetchService: IUserCardsFetchService
        
    /**
     Creates new `UserDictsFetchService`
     - Parameter innerQueue: queue where to perform async tasks
     - Parameter storageManager: instance for CRUD operations with CodeData objects
     - Parameter cardsFetchService: instance for updating/creating cards in dictionary
     */
    init(innerQueue: DispatchQueue,storageManager: IStorageCoordinator, cardsFetchService: IUserCardsFetchService) {
        self.innerQueue = innerQueue
        self.storageManager = storageManager
        self.cardsFetchService = cardsFetchService
    }
    
    func updateDicts(dicts: [GetDictionaryResponseDto], owner: DbAppUser, shouldDelete: Bool = true, completion: (() -> Void)?) {
        //let allUserDicts: [DbUserDictionary] = owner.dictionaries?.toArray() ?? []
        var updatedPins = Set<String>()
        let existingPins = Set(dicts.map { (el) -> String in
            return el.pin
        })
        
        let dispatchGroup = DispatchGroup()
        
        self.storageManager.stack.saveContext.performAndWait {
            let ownerInSaveContext = self.storageManager.stack.saveContext.object(with: owner.objectID) as! DbAppUser
            var toRemove: [DbUserDictionary] = []
            let allUserDicts: [DbUserDictionary] = ownerInSaveContext.dictionaries?.toArray() ?? []
            for dict in allUserDicts {
                if (!existingPins.contains(dict.pin!)) {
                    toRemove.append(dict)
                } else {
                    let updateDictDto = dicts.filter { (el) -> Bool in
                        el.pin == dict.pin
                    }.first
                    if let updateDictDto = updateDictDto {
                        updatedPins.insert(dict.pin!)
                        
                        dict.name = updateDictDto.name
                        dict.language = updateDictDto.language
                        //dispatchGroup.wait()
                        //updateCards
                        dispatchGroup.enter()
                        self.innerQueue.async {
                            self.cardsFetchService.updateCards(cards: updateDictDto.userCards, doSave: false, sourceDict: dict, completion: { () in
                                dispatchGroup.leave()
                            })
                        }
                    }
                }
            }
            
            if (shouldDelete) {
                for el in toRemove {
                    ownerInSaveContext.removeFromDictionaries(el)
                    self.storageManager.stack.saveContext.delete(el)
                }
            }
            
            for updateDictDto in dicts {
                if (!updatedPins.contains(updateDictDto.pin)) {
                    self.innerQueue.async {
                    //dispatchGroup.wait()
                    dispatchGroup.enter()
                        self.storageManager.createUserDictionary(owner: ownerInSaveContext, name: updateDictDto.name, timeCreated: updateDictDto.timeCreated, timeModified: updateDictDto.timeModified, language: updateDictDto.language, serverId: updateDictDto.id, cards: nil, pin: updateDictDto.pin) { (newDict) in
                            self.cardsFetchService.updateCards(cards: updateDictDto.userCards, doSave: true, sourceDict: newDict, completion: { () in
                                dispatchGroup.leave()
                            })
                        }
                    }
                }
            }
            self.innerQueue.async {
                dispatchGroup.wait()
                self.storageManager.performSave(in: self.storageManager.stack.saveContext, completion: completion)
            }
        }
    }
}
