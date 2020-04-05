//
//  DbUserTestDictExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserTestDict {
    
    func getCards() -> [DbUserTestCard] {
        return (self.cards?.allObjects ?? []) as! [DbUserTestCard]
    }
    
    static func insertUserTestDict(into context: NSManagedObjectContext) -> DbUserTestDict? {
        guard let testDict = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestDict", into: context) as? DbUserTestDict else {
            return nil
        }

        return testDict
    }

    static func fromDbUserDict(context: NSManagedObjectContext, dict: DbUserDictionary?, sourceTest: DbUserTest?) -> DbUserTestDict {
        guard let testDict = insertUserTestDict(into: context) else {
            fatalError("Cant create dbUserTestDict")
        }

        testDict.sourceTest = sourceTest
        testDict.name = dict?.name
        
        let _cards = dict?.userCards?.allObjects
        let cards = (_cards as? [DbUserCard] ?? [])
        let testCards: [DbUserTestCard] = cards.map { (card) -> DbUserTestCard in
            let testCard = DbUserTestCard.fromDbUserCard(context: context, card: card, sourceTestDict: testDict)
            return testCard
        }
        
        testCards.forEach { (card) in
            testDict.addToCards(card)
        }
                
        return testDict
    }
}
