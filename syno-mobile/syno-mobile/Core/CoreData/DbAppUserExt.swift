//
//  DbAppUserExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 30.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbAppUser {
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
                    print("Error in fetching \(err)")
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
