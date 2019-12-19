//
//  DbUserTestAnswer.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserTestAnswer {
    static func insertUserTestAnswer(into context: NSManagedObjectContext) -> DbUserTestAnswer? {
        guard let answer = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestAnswer", into: context) as? DbUserTestAnswer else {
            return nil
        }
        
        return answer
    }

    static func requestFromTestCard(sourceTestCard: DbUserTestCard) -> NSFetchRequest<DbUserTestAnswer> {
        let request: NSFetchRequest<DbUserTestAnswer> = DbUserTestAnswer.fetchRequest()
        request.predicate = NSPredicate(format: "sourceTestCard == %@", sourceTestCard)

        return request
    }
}
