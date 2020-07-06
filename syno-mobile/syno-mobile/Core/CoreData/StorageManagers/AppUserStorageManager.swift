import Foundation
import CoreData

class AppUserStorageManager: IAppUserStorageManager {
    func getCurrentUserEmail() -> String? {
        let user = self.getCurrentAppUser()!
        var email: String? = nil
        user.managedObjectContext?.performAndWait {
            email = user.email
        }
        return email
    }
    
    /// `NSManagedObjectContext` for saving in background
    var saveContext: NSManagedObjectContext {
        get {
            return self.stack.saveContext
        }
    }
    
    /// `NSManagedObjectContext` for main UI thread
    var mainContext: NSManagedObjectContext {
        get {
            return self.stack.mainContext
        }
    }
    
    /// stores CoreDataStack
    var stack: ICoreDataStack
    
    init(stack: ICoreDataStack) {
        self.stack = stack
    }
    
    func createAppUser(email: String, password: String, isCurrent: Bool) -> DbAppUser? {
        var user: DbAppUser?

        stack.mainContext.performAndWait {
            var res: [DbAppUser] = []
            
            do {
                res = try stack.mainContext.fetch(DbAppUser.requestByEmail(email: email))
            } catch let err {
                Logger.log("Cant fetch user by email: \(#function)")
                Logger.log(err.localizedDescription)
            }
            
            
            if !res.isEmpty {
                user = res.first!
            } else {
                user = DbAppUser.insertAppUser(into: self.mainContext)
            }
            
            self.mainContext.performAndWait {
                user?.email = email
                user?.password = password
                user?.isCurrent = isCurrent
                
                self.stack.performSave(with: self.mainContext, completion: { () -> Void in
                    if isCurrent {
                        self.markAppUserAsCurrent(user: user!)
                    }
                })
            }
        }
        
        return user
    }
    
    func getCurrentAppUser() -> DbAppUser? {
        var res: [DbAppUser] = []
        self.stack.mainContext.performAndWait {
            res = try! self.stack.mainContext.fetch(DbAppUser.requestActive())
        }
        return res.first
        
    }
    
    func markAppUserAsCurrent(user: DbAppUser) {
        self.mainContext.perform {
            let userObjectId = user.objectID
            let fetchRequest: NSFetchRequest<DbAppUser> = DbAppUser.fetchRequest()
            let allUsers = try! self.mainContext.fetch(fetchRequest)
            
            for usr in allUsers {
                if usr.objectID != userObjectId {
                    usr.isCurrent = false
                }
            }
            user.isCurrent = true
            self.stack.performSave(with: self.mainContext, completion: nil)
        }
    }
}

