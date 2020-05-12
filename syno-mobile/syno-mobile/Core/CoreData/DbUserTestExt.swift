import Foundation
import CoreData

extension DbUserTest {
    /// Checks if `DbUserTest` was completed by user
    func isEnded() -> Bool {
        return self.timePassed != nil
    }
    
    /// Ends tests and calculates results
    func endTest() {
        self.timePassed = Date()
        let allCnt = (self.targetedDict?.getCards() ?? []).map({ (card) -> Int in
            return card.getTranslations().count
        }).reduce(0) { (res, new) -> Int in
            return res + new
        }
        let passed = (self.testDict?.getCards() ?? []).flatMap({ (card) -> [DbUserTestTranslation] in
            return card.getTranslations()
        }).reduce(0, { (res, trans) -> Int32 in
            return res + (trans.isRightAnswered ? 1 : 0)
        })
        
        self.gradePercentage = Double(passed) * 100 / Double(allCnt)
    }
    
    /// Creates new `DbUserTest` and inserts it in given `context`
    static func insertUserTest(context: NSManagedObjectContext) -> DbUserTest? {
        guard let userTest = NSEntityDescription.insertNewObject(forEntityName: "DbUserTest", into: context) as? DbUserTest else {
            return nil
        }
        userTest.timeCreated = Date()

        return userTest
    }
    
    /// Creates new `DbUserTest` with given parameters and inserts it in given `context`
    /// - Parameter dict: dict for which should create `DbUserTest`
    static func createUserTestFor(context: NSManagedObjectContext, dict: DbUserDictionary) -> DbUserTest {
        guard let userTest = insertUserTest(context: context) else {
            fatalError("Cant insert DbUserTest")
        }
        userTest.targetedDict = dict
        userTest.testDict = DbUserTestDict.fromDbUserDict(context: context, dict: dict, sourceTest: userTest)
        
        return userTest
    }
    
    /// Creates `NSFetchRequest` to get last `limit` completed tests
    static func requestLatestTests(limit: Int = 5, owner: String) -> NSFetchRequest<DbUserTest> {
        let request: NSFetchRequest<DbUserTest> = DbUserTest.fetchRequest()
        request.fetchLimit = limit
        request.predicate = NSPredicate(format: "timePassed != NULL && targetedDict.owner.email = %@", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "timeCreated", ascending: false)]
        
        return request
    }
}
