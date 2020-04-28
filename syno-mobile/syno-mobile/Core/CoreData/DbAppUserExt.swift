import Foundation
import CoreData

extension DbAppUser {
    
    static func requestByEmail(email: String) -> NSFetchRequest<DbAppUser> {
        let request: NSFetchRequest<DbAppUser> = DbAppUser.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        return request
    }
    
    static func requestActive() -> NSFetchRequest<DbAppUser> {
        let request: NSFetchRequest<DbAppUser> = DbAppUser.fetchRequest()
        request.predicate = NSPredicate(format: "isCurrent == YES")
        
        return request
    }
    
    static func insertAppUser(into context: NSManagedObjectContext) -> DbAppUser? {
        guard let appUser = NSEntityDescription.insertNewObject(forEntityName: "DbAppUser", into: context) as? DbAppUser else {
            return nil
        }
        
        return appUser
    }
    
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
