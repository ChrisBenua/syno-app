import Foundation
import CoreData


class UserCardStorageManager: IUserCardsStorageManager {
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, pin: String?, completion: ((DbUserCard?) -> Void)?) {
        //DispatchQueue.global(qos: .background).async {
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
                    card?.addToTranslations(NSSet(array: trans))
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
        //}
    }
    
    var saveContext: NSManagedObjectContext {
        get {
            return self.stack.saveContext
        }
    }
    
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
