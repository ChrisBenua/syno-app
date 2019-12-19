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
    
    func getTranslations() -> [DbTranslation] {
        return (self.translations?.allObjects ?? []) as! [DbTranslation]
    }
    
    
    func toCellConfiguration() -> ICardCellConfiguration {
        return CardCellConfiguration(translatedWord: self.translatedWord, translations: (self.translations?.allObjects ?? []).map({ (translation) -> String? in
            (translation as! DbTranslation).translation
        }).filter({ (str) -> Bool in
            return str != nil
        }).map({ (trans) -> String in
            return trans!
        }))
    }
    
    public func setTranslatedWord(word: String?) {
        if self.translatedWord != word  {
            self.isSynced = false
            self.translatedWord = word
        }
    }

    public func setLanguage(language: String?) {
        if self.language != language {
            self.isSynced = false
            self.language = language
        }
    }
    
    public func addToTranslationsUpdateSync(translation: DbTranslation) {
        self.isSynced = false
        self.addToTranslations(translation)
    }
    
    public func addToTranslationsUpdateSync(translations: [DbTranslation]) {
        if translations.count > 0 {
            self.addToTranslations(NSSet(array: translations))
            self.isSynced = false
        }
    }
    
    static func insertUserCard(into context: NSManagedObjectContext) -> DbUserCard? {
        guard let userCard = NSEntityDescription.insertNewObject(forEntityName: "DbUserCard", into: context) as? DbUserCard else {
            return nil
        }
        
        return userCard
    }
    
    static func requestCardsFrom(sourceDict: DbUserDictionary) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "sourceDictionary == %@", sourceDict)
        request.sortDescriptors = [NSSortDescriptor(key: "translatedWord", ascending: true)]
        
        return request
    }
    
    static func requestCardWith(serverId: Int64) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        
        return request
    }
    
    static func requestCardWithIds(ids: [Int64]) -> NSFetchRequest<DbUserCard> {
        let request: NSFetchRequest<DbUserCard> = DbUserCard.fetchRequest()
        request.predicate = NSPredicate(format: "serverId IN %@", ids)
        
        return request
    }
    
    static func getCardWith(objectId: NSManagedObjectID, context: NSManagedObjectContext) -> DbUserCard? {
        return context.object(with: objectId) as? DbUserCard
    }
}
