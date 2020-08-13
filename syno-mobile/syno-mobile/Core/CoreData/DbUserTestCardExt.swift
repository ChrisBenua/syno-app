import Foundation
import CoreData

extension DbUserTestCard {
    /// Gets `DbUserTestCard` translations array
    func getTranslations() -> [DbUserTestTranslation] {
        return (self.translations?.allObjects ?? []) as! [DbUserTestTranslation]
    }
    
    /// Creates new empty `DbUserTestCard` in given `context`
    static func insertUserTestCard(into context: NSManagedObjectContext) -> DbUserTestCard? {
        guard let testCard = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestCard", into: context) as? DbUserTestCard else {
            return nil
        }
        
        return testCard
    }
    
    /**
     Creates new `DbUserTestCard` with given parameters and inserts it in given `context`
     - Parameter card: card where to add new `DbUserTestCard`
     - Parameter sourceTestDict: source dict where to add new `DbUserTestCard`
     */
    static func fromDbUserCard(context: NSManagedObjectContext, card: DbUserCard, sourceTestDict: DbUserTestDict?) -> DbUserTestCard {
        guard let testCard = insertUserTestCard(into: context) else {
            fatalError("Cant create DbUserTestCard")
        }
        testCard.sourceCard = card
        testCard.sourceTestDict = sourceTestDict
        testCard.translatedWord = card.translatedWord
        let _translations = card.translations?.array as? [DbTranslation]
        let translations = _translations ?? []
        var testTranslations: [DbUserTestTranslation] = []
        
        for translation in translations {
            testTranslations.append(DbUserTestTranslation.fromDbTranslation(context: context, translation: translation.translation, sourceTestCard: testCard))
        }
        testCard.addToTranslations(NSSet(array: testTranslations))
        
        return testCard
    }
}
