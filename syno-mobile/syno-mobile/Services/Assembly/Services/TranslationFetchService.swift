//
//  EntitiesFetchService.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 04.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol ITranslationFetchService {
    func updateTranslations(translations: [GetTranslationDto], doSave: Bool, sourceCardProvider: (GetTranslationDto) -> DbUserCard?, completion: (()->Void)?) -> Void
}

protocol IUserCardsFetchService {
    func updateCards(cards: [GetCardResponseDto], doSave: Bool, sourceDictProvider: (GetCardResponseDto) -> DbUserDictionary?, completion: (()->Void)?)
}

protocol IUserDictionaryFetchService {
    func updateDicts(dicts: [GetDictionaryResponseDto], owner: DbAppUser, completion: (()->Void)?)
}

class DbTranslationFetchService: ITranslationFetchService {

    private var storageManager: IStorageCoordinator
    private let innerQueue: DispatchQueue
    
    init(innerQueue: DispatchQueue, storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
        self.innerQueue = innerQueue
    }
    
    func updateTranslations(translations: [GetTranslationDto], doSave: Bool = false, sourceCardProvider: (GetTranslationDto) -> DbUserCard?, completion: (()->Void)?) {
        
        let serverIds = translations.map{ $0.id }
        
        let translationMap = Dictionary<Int64, GetTranslationDto>.init(uniqueKeysWithValues: translations.map({ ($0.id, $0) }))
        var notUsedIds = Set.init(serverIds)
        
        let request = DbTranslation.requestTranslationsWithIds(ids: serverIds)
        var res: [DbTranslation]?
        self.storageManager.stack.saveContext.performAndWait {
            //self.innerQueue.sync {
                do {
                    res = try self.storageManager.stack.saveContext.fetch(request)
                    
                    if let fetchedTranslations = res {
                        for translation in fetchedTranslations {
                            if let transDto = translationMap[translation.serverId] {
                                translation.comment = transDto.comment
                                translation.timeModified = transDto.timeModified
                                translation.transcription = transDto.transcription
                                translation.usageSample = transDto.usageSample
                                translation.serverId = transDto.id
                                
                                translation.isSynced = true

                                notUsedIds.remove(translation.serverId)
                            } else {
                                self.storageManager.stack.saveContext.delete(translation)
                            }
                        
                        }
                           
                        for notUsedId in notUsedIds {
                            if let transDto = translationMap[notUsedId] {
                                let sourceCard = sourceCardProvider(transDto)
                                
                                self.storageManager.createTranslation(sourceCard: sourceCard, usageSample: transDto.usageSample, translation: transDto.translation, transcription: transDto.transcription, comment: transDto.comment, serverId: transDto.id, timeCreated: transDto.timeCreated, timeModified: transDto.timeModified, completion: { (trans) -> Void in
                                    self.storageManager.performSave(in: self.storageManager.stack.saveContext, completion: completion)
                                })
                                sourceCard?.isSynced = true
                            }
                        }
                        
                        if doSave {
                            self.storageManager.performSave(in: self.storageManager.stack.saveContext, completion: completion)
                        } else {
                            completion?()
                        }
                    }
                } catch let err {
                    Logger.log("Cant fetch Translations in \(#function)")
                    Logger.log(err.localizedDescription)
                }
            //}
        }
    }
}
