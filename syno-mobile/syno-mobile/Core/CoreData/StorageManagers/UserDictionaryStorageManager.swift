import Foundation
import CoreData

class UserDictionaryStorageManager: IUserDictionaryStorageManager {
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, language: String?, serverId: Int64?, cards: [DbUserCard]?, pin: String?, completion: ((DbUserDictionary?) -> Void)?) {
            let ownerObjectId = owner.objectID
            
            let userDict = DbUserDictionary.insertUserDict(into: self.saveContext)
            
            self.saveContext.performAndWait {
                let ownerInSaveContext = self.saveContext.object(with: ownerObjectId) as? DbAppUser
                
                userDict?.name = name
                userDict?.language = language
                userDict?.timeCreated = timeCreated
                userDict?.timeModified = timeModified
                
                if let servId = serverId {
                    userDict?.serverId = servId
                }
                
                if let pin = pin {
                    userDict?.pin = pin
                }
                
                if let cards = cards {
                    userDict?.addToUserCards(NSSet(array: cards))
                }
                
                ownerInSaveContext?.addToDictionaries(userDict!)
                
                completion?(userDict)
            }
    }
    /// `NSManagedObjectContext` for saving in background
    var saveContext: NSManagedObjectContext {
        get {
            return self.stack.saveContext
        }
    }
    /// `NSManagedObjectContext` for accessing object in UI thread
    var mainContext: NSManagedObjectContext {
        get {
            return self.stack.mainContext
        }
    }
    
    var stack: ICoreDataStack
    
    init(stack: ICoreDataStack) {
        self.stack = stack
    }
}
