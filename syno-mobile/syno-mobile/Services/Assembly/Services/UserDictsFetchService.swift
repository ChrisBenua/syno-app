//
//  UserDictsFetchService.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IAtomicCounterSubscriber {
    var notifyOn: Int { get }
    func notify()
}

class AtomicCounter {
    private let innerQueue = DispatchQueue(label: "atomicCounterQueue", qos: .background, attributes: .concurrent)
    private var value: Int
    private var notifications: [IAtomicCounterSubscriber] = []
    
    init(value: Int = 0) {
        self.value = value
    }
    
    func increment() {
        innerQueue.async(flags: .barrier) {
            self.value += 1
            self.notifications.filter({ $0.notifyOn == self.value }).forEach { (sub) in
                sub.notify()
            }
        }
    }
    
    func decrement() {
        innerQueue.async(flags: .barrier) {
            self.value -= 1
            self.notifications.filter({ $0.notifyOn == self.value }).forEach { (sub) in
                sub.notify()
            }
        }
    }
    
    func get() -> Int {
        innerQueue.sync {
            self.value
        }
    }
    
    func subscribe(subscriber: IAtomicCounterSubscriber) {
        innerQueue.async(flags: .barrier) {
            self.notifications.append(subscriber)
        }
    }
}

class UserDictsFetchService: IUserDictionaryFetchService {
    
    private let innerQueue: DispatchQueue// = DispatchQueue(label: "UserDictsFetchService")
    
    private var storageManager: IStorageCoordinator
    
    private var cardsFetchService: IUserCardsFetchService
        
    init(innerQueue: DispatchQueue,storageManager: IStorageCoordinator, cardsFetchService: IUserCardsFetchService) {
        self.innerQueue = innerQueue
        self.storageManager = storageManager
        self.cardsFetchService = cardsFetchService
    }
    
    func updateDicts(dicts: [GetDictionaryResponseDto], owner: DbAppUser, completion: (() -> Void)?) {
        let serverIds = dicts.map{ $0.id }

        let dictsMap = Dictionary<Int64, GetDictionaryResponseDto>.init(uniqueKeysWithValues: dicts.map({($0.id, $0)}))
        var notUsedIds = Set.init(serverIds)
        
        let request = DbUserDictionary.requestDictWithIds(ids: serverIds)
        var res: [DbUserDictionary]?
        
        self.storageManager.stack.saveContext.performAndWait {
            //self.innerQueue.sync {
                do {
                    res = try self.storageManager.stack.saveContext.fetch(request)
                    
                    if let fetchedDicts = res {
                        for dict in fetchedDicts {
                            if let dictDto = dictsMap[dict.serverId] {
                                dict.name = dictDto.name
                                dict.timeModified = dictDto.timeModified
                                
                                self.cardsFetchService.updateCards(cards: dictDto.userCards, doSave: false, sourceDictProvider: { (cardDto) -> DbUserDictionary? in
                                    return dict
                                }, completion: nil)
                                
                                notUsedIds.remove(dictDto.id)
                                
                            } else {
                                self.storageManager.stack.saveContext.delete(dict)
                            }
                        }
                        
                        for notUsedId in notUsedIds {
                            if let dictDto = dictsMap[notUsedId] {
                                self.storageManager.createUserDictionary(owner: owner, name: dictDto.name, timeCreated: dictDto.timeCreated, timeModified: dictDto.timeModified, serverId: dictDto.id, cards: nil) { (newDict) in
                                    self.cardsFetchService.updateCards(cards: dictDto.userCards, doSave: true, sourceDictProvider: { (card) -> DbUserDictionary? in
                                        return newDict
                                    }, completion: nil)
                                }
                            }
                        }
                    }
                    
                    self.storageManager.performSave(in: self.storageManager.stack.saveContext, completion: completion)
                    
                } catch let err {
                    Logger.log("Cant fetch Dicts in \(#function)")
                    Logger.log(err.localizedDescription)
                }

            //}
        }
    }
    
    
}
