import Foundation
import CoreData


class UserCardStorageManager: IUserCardsStorageManager {
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, pin: String?, completion: ((DbUserCard?) -> Void)?) {
        let dictObjectId = sourceDict?.objectID
        
        let card = DbUserCard.insertUserCard(into: self.saveContext)
        
        self.saveContext.performAndWait {
            card?.translatedWord = translatedWord
            card?.timeCreated = timeCreated
            card?.timeModified = timeModified
            if let serverId = serverId {
                card?.serverId = serverId
            }
            
            if let trans = translation {
                card?.addToTranslations(NSOrderedSet(array: trans))
            }
            if let pin = pin {
                card?.pin = pin
            }
            
            if let dictObjectId = dictObjectId {
                let dictInSaveContext = self.saveContext.object(with: dictObjectId) as? DbUserDictionary
                if let card = card {
                    dictInSaveContext?.addToUserCards(card)
                }
            }

            completion?(card)
        }
    }
    
    /// `NSManagedObjectContext` for saving in background
    var saveContext: NSManagedObjectContext {
        get {
            return self.stack.saveContext
        }
    }
    /// `NSManagedObjectContext` for UI thread
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
