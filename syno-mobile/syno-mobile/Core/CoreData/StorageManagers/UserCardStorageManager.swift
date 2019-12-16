//
//  UserCardStorageManager.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 01.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData


class UserCardStorageManager: IUserCardsStorageManager {
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, language: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, completion: ((DbUserCard?) -> Void)?) {
        //DispatchQueue.global(qos: .background).async {
            let dictObjectId = sourceDict?.objectID
            
            let card = DbUserCard.insertUserCard(into: self.saveContext)
            
            self.saveContext.performAndWait {
                card?.translatedWord = translatedWord
                card?.language = language
                card?.timeCreated = timeCreated
                card?.timeModified = timeModified
                if let serverId = serverId {
                    card?.serverId = serverId
                }
                
                if let trans = translation {
                    card?.addToTranslationsUpdateSync(translations: trans)
                }
                
                if let dictObjectId = dictObjectId {
                    let dictInSaveContext = self.saveContext.object(with: dictObjectId) as? DbUserDictionary
                    if let card = card {
                        dictInSaveContext?.addToCardsUpdateSync(card: card)
                    }
                }

                completion?(card)
            }
        //}
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
