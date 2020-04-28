import Foundation
import CoreData

extension DbUserTestTranslation {
    static func insertUserTestTranslation(into context: NSManagedObjectContext) -> DbUserTestTranslation? {
        guard let testTranslation = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestTranslation", into: context) as? DbUserTestTranslation else {
            return nil
        }
        
        return testTranslation
    }
    
    static func fromDbTranslation(context: NSManagedObjectContext, translation: String?, sourceTestCard: DbUserTestCard?) -> DbUserTestTranslation {
        guard let testTranslation = insertUserTestTranslation(into: context) else {
            fatalError("Cant insert UserTestTranslation")
        }
        testTranslation.translation = translation
        testTranslation.isRightAnswered = false
        sourceTestCard?.addToTranslations(testTranslation)
        
        return testTranslation
    }
    
    static func requestFromTestCard(testCard: DbUserTestCard) -> NSFetchRequest<DbUserTestTranslation> {
        let request: NSFetchRequest<DbUserTestTranslation> = DbUserTestTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "sourceTestCard == %@", testCard)
        
        return request
    }
}
