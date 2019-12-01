//
//  DbUserDictionaryExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 30.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserDictionary {
    static func insertUserDict(into context: NSManagedObjectContext) -> DbUserDictionary? {
        guard let dict = NSEntityDescription.insertNewObject(forEntityName: "DbUserDictionary", into: context) as? DbUserDictionary else {
            return nil
        }
        
        return dict
    }
    
    static func requestDictWith(dictServerId: Int64) -> NSFetchRequest<DbUserDictionary> {
        let request: NSFetchRequest<DbUserDictionary> = DbUserDictionary.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", dictServerId)
        
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
