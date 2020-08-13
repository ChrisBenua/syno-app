import Foundation
import CoreData

extension DbUserCard {
    /// Gets `DbUserCard` translations array
    func getTranslations() -> [DbTranslation] {
        return (self.translations?.array ?? []) as! [DbTranslation]
    }
    
    /// Converts `DbUserCard` to `ICardCellConfiguration`
    func toCellConfiguration() -> ICardCellConfiguration {
        return CardCellConfiguration(translatedWord: self.translatedWord, translations: (self.translations?.array ?? []).map({ (translation) -> String? in
            (translation as! DbTranslation).translation
        }).filter({ (str) -> Bool in
            return str != nil
        }).map({ (trans) -> String in
            return trans!
        }))
    }
    
    /// Creates new empty `DbUserCard` and inserts it in given `context`
    static func insertUserCard(into context: NSManagedObjectContext) -> DbUserCard? {
        var userCard: DbUserCard? = nil
        context.performAndWait {
            userCard = NSEntityDescription.insertNewObject(forEntityName: "DbUserCard", into: context) as? DbUserCard
            userCard?.pin = PinGenerator.generatePin()
        }
        return userCard
    }
    
    /// Creates `NSFetchRequest` for fetching cards from given `sourceDict` sorted by translated word
    static func requestCardsFrom(sourceDict: DbUserDictionary) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "sourceDictionary == %@", sourceDict)
        request.sortDescriptors = [NSSortDescriptor(key: "translatedWord", ascending: true)]
        
        return request
    }
    
    /// Gets `DbUserCard` with given `objectId` in given `context`
    static func getCardWith(objectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbUserCard? {
        return context.object(with: objectId) as? DbUserCard
    }
}
