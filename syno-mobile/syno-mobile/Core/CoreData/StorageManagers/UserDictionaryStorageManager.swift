//
//  UserDictionaryStorageManager.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 01.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

class UserDictionaryStorageManager: IUserDictionaryStorageManager {
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, cards: [DbUserCard]?) {
        DispatchQueue.global(qos: .background).async {
            let ownerObjectId = owner.objectID
            
            let userDict = DbUserDictionary.insertUserDict(into: self.saveContext)
            
            self.saveContext.performAndWait {
                let ownerInSaveContext = self.saveContext.object(with: ownerObjectId) as? DbAppUser
                
                userDict?.name = name
                userDict?.timeCreated = timeCreated
                userDict?.timeModified = timeModified
                
                if let servId = serverId {
                    userDict?.serverId = servId
                }
                
                if let cards = cards {
                    userDict?.addToUserCards(NSSet(array: cards))
                }
                
                ownerInSaveContext?.addToDictionaries(userDict!)
                
                self.stack.performSave(with: self.saveContext, completion: nil)
            }
        }
    }
    
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
}
