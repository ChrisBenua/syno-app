//
//  AppUserStorageManager.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 01.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

class AppUserStorageManager: IAppUserStorageManager {
    
    var saveContext: NSManagedObjectContext {
        get {
            return self.stack.saveContext
        }
    }
    
    var mainContext: NSManagedObjectContext {
        get {
            return self.stack.mainContext
        }
    }
    
    var stack: ICoreDataStack
    
    init(stack: ICoreDataStack) {
        self.stack = stack
    }
    
    func createAppUser(email: String, password: String, isCurrent: Bool) -> DbAppUser? {
        var res: [DbAppUser] = []
        
        do {
            res = try stack.mainContext.fetch(DbAppUser.requestByEmail(email: email))
        } catch let err {
            Logger.log("Cant fetch user by email: \(#function)")
            Logger.log(err.localizedDescription)
        }
        
        var user: DbAppUser?
        
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
        return user
    }
    
    func getCurrentAppUser() -> DbAppUser? {
        return try? stack.mainContext.fetch(DbAppUser.requestActive()).first
    }
    
    func markAppUserAsCurrent(user: DbAppUser) {
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

