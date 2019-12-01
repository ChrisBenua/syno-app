//
//  DbUserCardExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 30.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserCard {
    static func insertUserCard(into context: NSManagedObjectContext) -> DbUserCard? {
        guard let userCard = NSEntityDescription.insertNewObject(forEntityName: "DbUserCard", into: context) as? DbUserCard else {
            return nil
        }
        
        return userCard
    }
    
    static func requestCardWith(serverId: Int64) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        
        return request
    }
    
    static func getCardWith(objectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbUserCard? {
        return context.object(with: objectId) as? DbUserCard
    }
}
