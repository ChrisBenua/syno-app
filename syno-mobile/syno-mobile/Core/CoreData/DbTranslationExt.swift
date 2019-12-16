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
    
    func toTranslationCellConfig() -> ITranslationCellConfiguration {
        return TranslationCellConfiguration(translation: translation, transcription: transcription, comment: comment, sample: usageSample)
    }
    
    public func setComment(comment: String?) {
        if self.comment != comment {
            self.comment = comment
            self.isSynced = false
        }
    }
    
    public func setTranslation(translation: String?) {
        if self.translation != translation {
            self.translation = translation
            self.isSynced = false
        }
    }
    
    public func setTranscription(transcription: String?) {
        if self.transcription != transcription {
            self.transcription = transcription
            self.isSynced = false
        }
    }
    
    public func setUsageSample(sample: String?) {
        if self.usageSample != sample {
            self.usageSample = sample
            self.isSynced = false
        }
    }
    
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
    
    static func requestTranslationsWithIds(ids: [Int64]) -> NSFetchRequest<DbTranslation> {
        let request: NSFetchRequest<DbTranslation> = DbTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "serverId IN %@", ids)
        
        return request
    }
    
    static func requestTranslationsFrom(sourceCard: DbUserCard) -> NSFetchRequest<DbTranslation> {
        let request: NSFetchRequest<DbTranslation> = DbTranslation.fetchRequest()
        request.predicate = NSPredicate(format: "sourceCard == %@", sourceCard)
        request.sortDescriptors = [NSSortDescriptor(key: "translation", ascending: true)]
        
        return request
    }

}
