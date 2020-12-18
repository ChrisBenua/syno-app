import Foundation
import CoreData

extension DbUserDictionary {
    
    func getTranslationsLanguage() -> String? {
        if let lan = self.language?.split(separator: "-").last {
            return String(lan)
        }
        return nil
    }
    
    /// Gets `DbUserDictionary` cards array
    func getCards() -> [DbUserCard] {
        return (self.userCards?.allObjects ?? []) as! [DbUserCard]
    }
    
    /// Converts `DbUserDictionary` to `ITestAndLearnCellConfiguration`
    func toTestAndLearnCellConfiguration() -> ITestAndLearnCellConfiguration {
        let allTest: [DbUserTest] = self.tests?.toArray() ?? []
        let lastPassedTest = allTest.sorted(by: { (lhs, rhs) -> Bool in
            (lhs.timePassed ?? lhs.timeCreated!) > (rhs.timePassed ?? rhs.timeCreated!)
        }).first { (test) -> Bool in
            test.isEnded()
        }
        
        return TestAndLearnCellConfiguration(dictionaryName: self.name, language: self.language, gradePercentage: lastPassedTest?.gradePercentage ?? -1.0)
    }
    
    /// Converts `DbUserDictionary` to `IDictionaryCellConfiguration`
    func toUserDictCellConfig() -> IDictionaryCellConfiguration {
        let allObjects = self.userCards?.allObjects
        let cardsAmount = allObjects?.count ?? 0
        let transAmount = (allObjects ?? []).reduce(0) { (result, elem) -> Int in
            return result + ((elem as? DbUserCard)?.translations?.count ?? 0)
        }
        
        return DictionaryCellConfiguration(dictName: self.name, language: self.language, cardsAmount: cardsAmount, translationsAmount: transAmount)
    }
    
    /// Creates new empty `DbUserDictionary` and inserts it in given `context`
    static func insertUserDict(into context: NSManagedObjectContext) -> DbUserDictionary? {
        var dict: DbUserDictionary? = nil
        context.performAndWait {
            dict = NSEntityDescription.insertNewObject(forEntityName: "DbUserDictionary", into: context) as? DbUserDictionary
            dict?.pin = PinGenerator.generatePin()

        }
        
        return dict
    }
    
    /// Creates `NSFetchRequest` to fetch given `DbAppUser` dictionaries sorted by name
    static func requestSortedByName(owner: DbAppUser) -> NSFetchRequest<DbUserDictionary> {
        let request: NSFetchRequest<DbUserDictionary> = DbUserDictionary.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@ AND wasDeletedManually == NO", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "timeCreated", ascending: false), NSSortDescriptor(key: "name", ascending: false)]
        
        return request
    }
    
    static func requestDeletedSortedByDate(owner: DbAppUser) -> NSFetchRequest<DbUserDictionary> {
        let request: NSFetchRequest<DbUserDictionary> = DbUserDictionary.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@ AND wasDeletedManually == YES", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "timeCreated", ascending: false), NSSortDescriptor(key: "name", ascending: false)]
        
        return request
    }
}
