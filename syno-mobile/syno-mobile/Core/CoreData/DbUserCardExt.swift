import Foundation
import CoreData

extension DbUserCard {
    
    func getTranslations() -> [DbTranslation] {
        return (self.translations?.allObjects ?? []) as! [DbTranslation]
    }
    
    
    func toCellConfiguration() -> ICardCellConfiguration {
        return CardCellConfiguration(translatedWord: self.translatedWord, translations: (self.translations?.allObjects ?? []).map({ (translation) -> String? in
            (translation as! DbTranslation).translation
        }).filter({ (str) -> Bool in
            return str != nil
        }).map({ (trans) -> String in
            return trans!
        }))
    }
    
    static func insertUserCard(into context: NSManagedObjectContext) -> DbUserCard? {
        var userCard: DbUserCard? = nil
        context.performAndWait {
            userCard = NSEntityDescription.insertNewObject(forEntityName: "DbUserCard", into: context) as? DbUserCard
            userCard?.pin = PinGenerator.generatePin()
        }
        return userCard
    }
    
    static func requestCardsFrom(sourceDict: DbUserDictionary) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "sourceDictionary == %@", sourceDict)
        request.sortDescriptors = [NSSortDescriptor(key: "translatedWord", ascending: true)]
        
        return request
    }
    
    static func requestCardWith(serverId: Int64) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        
        return request
    }
    
    static func requestCardWithIds(ids: [Int64]) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest<DbUserCard> = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "serverId IN %@", ids)
        
        return request
    }
    
    static func getCardWith(objectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbUserCard? {
        return context.object(with: objectId) as? DbUserCard
    }
}
