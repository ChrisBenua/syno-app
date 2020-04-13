//
//  UserCardsFetchService.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

class UserCardsFetchService: IUserCardsFetchService {
    
    private let innerQueue: DispatchQueue
    private var storageManager: IStorageCoordinator
    
    private var translationsFetchService: ITranslationFetchService
        
    init(innerQueue: DispatchQueue, storageManager: IStorageCoordinator, translationsFetchService: ITranslationFetchService) {
        self.storageManager = storageManager
        self.innerQueue = innerQueue
        self.translationsFetchService = translationsFetchService
    }
    
    func updateCards(cards: [GetCardResponseDto], doSave: Bool, sourceDictProvider: (GetCardResponseDto) -> DbUserDictionary?, completion: (()->Void)?) {
        let serverIds = cards.map{ $0.id }
        
        let cardsMap = Dictionary<Int64, GetCardResponseDto>.init(uniqueKeysWithValues: cards.map({ ($0.id, $0) }))
        var notUsedIds = Set.init(serverIds)
        
        let request = DbUserCard.requestCardWithIds(ids: serverIds)
        var res: [DbUserCard]?
        
        self.storageManager.stack.saveContext.performAndWait {
            //innerQueue.sync {
                do {
                    res = try self.storageManager.stack.saveContext.fetch(request)

                    if let fetchedCards = res {
                        for card in fetchedCards {
                            if let cardDto = cardsMap[card.serverId] {
                                card.translatedWord = cardDto.translatedWord
                                card.timeModified = cardDto.timeModified
                                card.timeCreated = cardDto.timeCreated
                                card.serverId = cardDto.id
                                
                                self.translationsFetchService.updateTranslations(translations: cardDto.translations, doSave: false, sourceCardProvider: { (trans_) -> DbUserCard? in
                                    return card
                                }, completion: nil)
                                notUsedIds.remove(cardDto.id)

                            } else {
                                self.storageManager.stack.saveContext.delete(card)
                            }
                        }

                        for notUsedId in notUsedIds {
                            if let cardDto = cardsMap[notUsedId] {
                                let sourceDict = sourceDictProvider(cardDto)
                                
                                self.storageManager.createUserCard(sourceDict: sourceDict, translatedWord: cardDto.translatedWord, timeCreated: cardDto.timeCreated, timeModified: cardDto.timeModified, serverId: cardDto.id, translation: nil) { (newCard) in
                                    self.translationsFetchService.updateTranslations(translations: cardDto.translations, doSave: true, sourceCardProvider: { (trans) -> DbUserCard? in
                                        newCard
                                    }, completion: nil)
                                    
                                    sourceDict?.isSynced = true
                                }
                            }
                        }
                    }
                    
                    if doSave {
                        self.storageManager.performSave(in: self.storageManager.stack.saveContext)
                    }
                    
                } catch let err {
                    Logger.log("Cant fetch Cards in \(#function)")
                    Logger.log(err.localizedDescription)
                }
            //}
        }
    }
}
