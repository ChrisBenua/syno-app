import Foundation
import CoreData

extension DbTranslation {
    
    func toTranslationCellConfig() -> ITranslationCellConfiguration {
        return TranslationCellConfiguration(translation: translation, transcription: transcription, comment: comment, sample: usageSample)
    }
    
    static func insertTranslation(into context: NSManagedObjectContext) -> DbTranslation? {
        var trans: DbTranslation? = nil
        context.performAndWait {
            trans = NSEntityDescription.insertNewObject(forEntityName: "DbTranslation", into: context) as? DbTranslation
        
        
            trans?.pin = PinGenerator.generatePin()
        }
        return trans
    }
    
    static func requestTranslationWith(serverId: Int64) -> NSFetchRequest<DbTranslation> {
        let request: NSFetchRequest<DbTranslation> = DbTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        
        return request
    }
    
    static func getTranslationWith(objectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbTranslation? {
        return context.object(with: objectId) as? DbTranslation
    }
    
    static func requestTranslationsWithIds(ids: [Int64]) -> NSFetchRequest<DbTranslation> {
        let request: NSFetchRequest<DbTranslation> = DbTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "serverId IN %@", ids)
        
        return request
    }
    
    static func requestTranslationsFrom(sourceCard: DbUserCard) -> NSFetchRequest<DbTranslation> {
        let request: NSFetchRequest<DbTranslation> = DbTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "sourceCard == %@", sourceCard)
        request.sortDescriptors = [NSSortDescriptor(key: "translation", ascending: true)]
        
        return request
    }

}
