import Foundation
import CoreData

extension DbUserTestDict {
    /// Gets `DbUserTestDict` cards array
    func getCards() -> [DbUserTestCard] {
        return (self.cards?.allObjects ?? []) as! [DbUserTestCard]
    }
    
    /// Creates new `DbUserTestDict` and inserts it in given `context`
    static func insertUserTestDict(into context: NSManagedObjectContext) -> DbUserTestDict? {
        guard let testDict = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestDict", into: context) as? DbUserTestDict else {
            return nil
        }

        return testDict
    }

    /**
     Creates new `DbUserTestDict` with given parameters and inserts it in given `context`
     - Parameter dict: `DbUserDictionary` where to add new `DbUserTestDict`
     - Parameter sourceTest: `DbUserTest` where to add new `DbUserTestDict`
     */
    static func fromDbUserDict(context: NSManagedObjectContext, dict: DbUserDictionary?, sourceTest: DbUserTest?) -> DbUserTestDict {
        guard let testDict = insertUserTestDict(into: context) else {
            fatalError("Cant create dbUserTestDict")
        }

        testDict.sourceTest = sourceTest
        testDict.name = dict?.name
        
        let _cards = dict?.userCards?.allObjects
        let cards = (_cards as? [DbUserCard] ?? [])
        let testCards: [DbUserTestCard] = cards.map { (card) -> DbUserTestCard in
            let testCard = DbUserTestCard.fromDbUserCard(context: context, card: card, sourceTestDict: testDict)
            return testCard
        }
        
        testCards.forEach { (card) in
            testDict.addToCards(card)
        }
                
        return testDict
    }
}
