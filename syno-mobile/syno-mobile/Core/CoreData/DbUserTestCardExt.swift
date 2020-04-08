//
//  DbUserTestCardExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserTestCard {
    
    func getTranslations() -> [DbUserTestTranslation] {
        return (self.translations?.allObjects ?? []) as! [DbUserTestTranslation]
    }
    
    static func insertUserTestCard(into context: NSManagedObjectContext) -> DbUserTestCard? {
        guard let testCard = NSEntityDescription.insertNewObject(forEntityName: "DbUserTestCard", into: context) as? DbUserTestCard else {
            return nil
        }
        
        return testCard
    }
    
    //Additionaly set shuffle number!!!
    static func fromDbUserCard(context: NSManagedObjectContext, card: DbUserCard, sourceTestDict: DbUserTestDict?) -> DbUserTestCard {
        guard let testCard = insertUserTestCard(into: context) else {
            fatalError("Cant create DbUserTestCard")
        }
        testCard.sourceCard = card
        testCard.sourceTestDict = sourceTestDict
        testCard.translatedWord = card.translatedWord
        let _translations = card.translations?.allObjects as? [DbTranslation]
        let translations = _translations ?? []
        var testTranslations: [DbUserTestTranslation] = []
        
        for translation in translations {
            testTranslations.append(DbUserTestTranslation.fromDbTranslation(context: context, translation: translation.translation, sourceTestCard: testCard))
        }
        testCard.addToTranslations(NSSet(array: testTranslations))
        
        return testCard
    }
    
    static func requestFromTestDict(sourceDict: DbUserTestDict) -> NSFetchRequest<DbUserTestCard> {
        let request: NSFetchRequest<DbUserTestCard> = DbUserTestCard.fetchRequest()
        request.predicate = NSPredicate(format: "sourceTestDict == %@", sourceDict)
        request.sortDescriptors = [NSSortDescriptor(key: "shuffleNumber", ascending: true)]
        
        return request
    }
}
