//
//  DbTranslationExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 01.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbTranslation {
    static func insertTranslation(into context: NSManagedObjectContext) -> DbTranslation? {
        guard let trans = NSEntityDescription.insertNewObject(forEntityName: "DbTranslation", into: context) as? DbTranslation else {
            return nil
        }
        
        return trans
    }
    
    static func requestTranslationWith(serverId: Int64) -> NSFetchRequest<DbTranslation> {
        let request: NSFetchRequest<DbTranslation> = DbTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        
        return request
    }
    
    static func getTranslationWith(objectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbTranslation? {
        return context.object(with: objectId) as? DbTranslation
    }

}
