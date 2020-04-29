import Foundation
import CoreData

extension DbUserTestTranslation {
    /// Creates new empty `DbUserTestTranslation` and inserts it in given `context`
    static func insertUserTestTranslation(into context: NSManagedObjectContext) -> DbUserTestTranslation? {
        guard let testTranslation = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestTranslation", into: context) as? DbUserTestTranslation else {
            return nil
        }
        
        return testTranslation
    }
    
    /// Creates new `DbUserTestTranslation` with given parameters and inserts it in given `context`
    /// - Parameter translation: actual translation
    /// - Parameter sourceTestCard: `DbUserTestCard` where to add new `DbUserTestTranslation`
    static func fromDbTranslation(context: NSManagedObjectContext, translation: String?, sourceTestCard: DbUserTestCard?) -> DbUserTestTranslation {
        guard let testTranslation = insertUserTestTranslation(into: context) else {
            fatalError("Cant insert UserTestTranslation")
        }
        testTranslation.translation = translation
        testTranslation.isRightAnswered = false
        sourceTestCard?.addToTranslations(testTranslation)
        
        return testTranslation
    }
}
