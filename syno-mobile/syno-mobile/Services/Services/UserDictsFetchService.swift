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
            let allUserDicts: [DbUserDictionary] = ownerInSaveContext.getDictionaries(includeDeletedManually: false)
            //allUserDicts = allUserDicts.filter{ !$0.wasDeletedManually }
            let trashDicts: [DbUserDictionary] = ownerInSaveContext.getDictionaries(includeDeletedManually: true).filter({ $0.wasDeletedManually })
            
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
                    el.wasDeletedManually = true
                }
            }
            
            for updateDictDto in dicts.sorted(by: { $0.timeCreated > $1.timeCreated }) {
                if (!updatedPins.contains(updateDictDto.pin)) {
                    if let dict = trashDicts.first(where: { $0.pin == updateDictDto.pin }) {
                        ownerInSaveContext.removeFromDictionaries(dict)
                        self.storageManager.stack.saveContext.delete(dict)
                    }
                    self.innerQueue.async {
                    //dispatchGroup.wait()
                    Logger.log("Dict: name: \(updateDictDto.name), \(updateDictDto.timeCreated)")
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
