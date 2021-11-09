import Foundation
import CoreData

extension DbAppUser {
    /// Creates `NSFetchRequest` to fetching users with given `email`
    /// - Parameter email: users with which email to fetch
    static func requestByEmail(email: String) -> NSFetchRequest<DbAppUser> {
        let request: NSFetchRequest<DbAppUser> = DbAppUser.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        return request
    }
    
    /// Creates new `DbAppUser` and inserts in given `context`
    static func insertAppUser(into context: NSManagedObjectContext) -> DbAppUser? {
        guard let appUser = NSEntityDescription.insertNewObject(forEntityName: "DbAppUser", into: context) as? DbAppUser else {
            return nil
        }
        
        return appUser
    }
    
    /// Gets user or creates one if there is none in given `context`
    /// - Parameter completion: completion callback
    static func getOrCreateAppUser(in context: NSManagedObjectContext, completion: ((DbAppUser?) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<DbAppUser> = DbAppUser.fetchRequest()
            var foundUser: DbAppUser?
            
            context.perform {
                do {
                    
                    let result = try context.fetch(fetchRequest)
                    if let user = result.first {
                        foundUser = user
                    }
                } catch let err {
                    Logger.log("Error in fetching \(err)")
                }
                if foundUser == nil {
                    foundUser = DbAppUser.insertAppUser(into: context)
                }
                DispatchQueue.main.async {
                    completion?(foundUser)
                }
            }
        }
    }
}
