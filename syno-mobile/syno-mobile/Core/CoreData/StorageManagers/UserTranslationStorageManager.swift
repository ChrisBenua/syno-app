import Foundation
import CoreData


class UserTranslationStorageManager: ITranslationsStorageManager {
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, serverId: Int64?, timeCreated: Date?, timeModified: Date?, pin: String?, completion: ((DbTranslation?) -> Void)?) {
        //DispatchQueue.global(qos: .background).async {
            let sourceCardObjectId = sourceCard?.objectID
            
            let dbTranslation = DbTranslation.insertTranslation(into: self.saveContext)
            
            self.saveContext.performAndWait {
                dbTranslation?.comment = comment
                dbTranslation?.usageSample = usageSample
                dbTranslation?.transcription = transcription
                dbTranslation?.translation = translation
                dbTranslation?.timeCreated = timeCreated
                dbTranslation?.timeModified = timeModified
                if let servId = serverId {
                    dbTranslation?.serverId = servId
                }
                
                if let pin = pin {
                    dbTranslation?.pin = pin
                }
                
                if let objId = sourceCardObjectId {
                    let cardInSaveCtx_ = DbUserCard.getCardWith(objectId: objId, context: self.saveContext)
                    if let cardInSaveCtx = cardInSaveCtx_ {
                        cardInSaveCtx.addToTranslations(dbTranslation!)
                        dbTranslation?.sourceCard = cardInSaveCtx
                    }
                }
                
                completion?(dbTranslation)
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
