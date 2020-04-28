import Foundation
import CoreData

extension DbUserDictionary {
    
    func getCards() -> [DbUserCard] {
        return (self.userCards?.allObjects ?? []) as! [DbUserCard]
    }
    
    func toTestAndLearnCellConfiguration() -> ITestAndLearnCellConfiguration {
        let allTest: [DbUserTest] = self.tests?.toArray() ?? []
        let lastPassedTest = allTest.sorted(by: { (lhs, rhs) -> Bool in
            (lhs.timePassed ?? lhs.timeCreated!) > (rhs.timePassed ?? rhs.timeCreated!)
        }).first { (test) -> Bool in
            test.isEnded()
        }
        
        return TestAndLearnCellConfiguration(dictionaryName: self.name, language: self.language, gradePercentage: lastPassedTest?.gradePercentage ?? -1.0)
    }
    
    func toUserDictCellConfig() -> IDictionaryCellConfiguration {
        let allObjects = self.userCards?.allObjects
        let cardsAmount = allObjects?.count ?? 0
        let transAmount = (allObjects ?? []).reduce(0) { (result, elem) -> Int in
            return result + ((elem as? DbUserCard)?.translations?.count ?? 0)
        }
        
        
        return DictionaryCellConfiguration(dictName: self.name, language: self.language, cardsAmount: cardsAmount, translationsAmount: transAmount)
    }
    
    public func setName(name: String?) {
        if self.name != name {
            self.name = name
        }
    }
    
    static func insertUserDict(into context: NSManagedObjectContext) -> DbUserDictionary? {
        var dict: DbUserDictionary? = nil
        context.performAndWait {
            dict = NSEntityDescription.insertNewObject(forEntityName: "DbUserDictionary", into: context) as? DbUserDictionary
            dict?.pin = PinGenerator.generatePin()

        }
        
        return dict
    }
    
    static func requestDictWith(dictServerId: Int64) -> NSFetchRequest<DbUserDictionary> {
        let request: NSFetchRequest<DbUserDictionary> = DbUserDictionary.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", dictServerId)
        
        return request
    }
    
    static func requestDictWithIds(ids: [Int64]) -> NSFetchRequest<DbUserDictionary> {
        let request: NSFetchRequest<DbUserDictionary> = DbUserDictionary.fetchRequest()
        request.predicate = NSPredicate(format: "serverId IN %@", ids)
        
        return request
    }
    
    static func requestSortedByName(owner: DbAppUser) -> NSFetchRequest<DbUserDictionary> {
        let request: NSFetchRequest<DbUserDictionary> = DbUserDictionary.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        return request
    }
    
    static func getDictByObjectId(dictObjectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbUserDictionary? {
        do {
            return try context.existingObject(with: dictObjectId) as? DbUserDictionary
        } catch let err {
            Logger.log(#function + " error: \(err.localizedDescription)")
            return nil
        }
    }
}
