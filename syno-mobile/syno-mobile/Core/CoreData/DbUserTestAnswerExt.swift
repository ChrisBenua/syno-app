import Foundation
import CoreData

extension DbUserTestAnswer {
    /// Creates new `DbUserTestAnswer` and inserts it in given `context`
    static func insertUserTestAnswer(into context: NSManagedObjectContext) -> DbUserTestAnswer? {
        guard let answer = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestAnswer", into: context) as? DbUserTestAnswer else {
            return nil
        }
        
        return answer
    }
}
