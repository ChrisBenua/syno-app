import Foundation
import CoreData

extension DbTranslation {
    /// Converts `DbTranslation` to `ITranslationCellConfiguration`
    func toTranslationCellConfig() -> ITranslationCellConfiguration {
        return TranslationCellConfiguration(translation: translation, transcription: transcription, comment: comment, sample: usageSample)
    }
    
    /// Creates new empty `DbTranslation` and inserts it in given context
    static func insertTranslation(into context: NSManagedObjectContext) -> DbTranslation? {
        var trans: DbTranslation? = nil
        context.performAndWait {
            trans = NSEntityDescription.insertNewObject(forEntityName: "DbTranslation", into: context) as? DbTranslation
            trans?.pin = PinGenerator.generatePin()
        }
        return trans
    }
}
