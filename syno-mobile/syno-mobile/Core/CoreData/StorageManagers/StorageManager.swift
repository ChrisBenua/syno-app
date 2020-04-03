//
//  StorageManager.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 30.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData


protocol IAppUserStorageManager {
    func getCurrentAppUser() -> DbAppUser?
    
    func createAppUser(email: String, password: String, isCurrent: Bool) -> DbAppUser?
    
    func markAppUserAsCurrent(user: DbAppUser)
}

protocol IUserDictionaryStorageManager {
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, cards: [DbUserCard]?, completion: ((DbUserDictionary?) -> Void)?)
}

protocol IUserCardsStorageManager {
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, language: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, completion: ((DbUserCard?) -> Void)?)
}

protocol ITranslationsStorageManager {
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, serverId: Int64?, timeCreated: Date?, timeModified: Date?, completion: ((DbTranslation?) -> Void)?)
}

protocol IStorageCoordinator: IAppUserStorageManager, IUserDictionaryStorageManager, IUserCardsStorageManager, ITranslationsStorageManager {
    static var shared: IStorageCoordinator { get }
    
    var stack: ICoreDataStack { get }
       
    func performSave(in context: NSManagedObjectContext)
    
    func performSave(in context: NSManagedObjectContext, completion: (() -> Void)?)
}

class StorageManager: IStorageCoordinator {
    func getCurrentAppUser() -> DbAppUser? {
        return self.userManager.getCurrentAppUser()
    }
    
    func performSave(in context: NSManagedObjectContext) {
        DispatchQueue.global(qos: .background).async {
            self.stack.performSave(with: context, completion: nil)
        }
    }
    
    func performSave(in context: NSManagedObjectContext, completion: (() -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            self.stack.performSave(with: context, completion: completion)
        }
    }
    
    func createAppUser(email: String, password: String, isCurrent: Bool) -> DbAppUser? {
        self.userManager.createAppUser(email: email, password: password, isCurrent: isCurrent)
    }
    
    func markAppUserAsCurrent(user: DbAppUser) {
        self.userManager.markAppUserAsCurrent(user: user)
    }
    
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, cards: [DbUserCard]?, completion: ((DbUserDictionary?) -> Void)?) {
        self.dictManager.createUserDictionary(owner: owner, name: name, timeCreated: timeCreated, timeModified: timeModified, serverId: serverId, cards: cards, completion: completion)
    }
    
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, language: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, completion: ((DbUserCard?) -> Void)?) {
        self.cardsManager.createUserCard(sourceDict: sourceDict, translatedWord: translatedWord, language: language, timeCreated: timeCreated, timeModified: timeModified, serverId: serverId, translation: translation, completion: completion)
    }
    
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, serverId: Int64?, timeCreated: Date?, timeModified: Date?, completion: ((DbTranslation?) -> Void)?) {
        self.transManager.createTranslation(sourceCard: sourceCard, usageSample: usageSample, translation: translation, transcription: transcription, comment: comment, serverId: serverId, timeCreated: timeCreated, timeModified: timeModified, completion: completion)
    }
    

    static var shared: IStorageCoordinator = StorageManager()

    private var privateStack: ICoreDataStack

    public var stack: ICoreDataStack {
        get {
            return privateStack
        }
    }

    private var userManager: IAppUserStorageManager
    
    private var dictManager: IUserDictionaryStorageManager
    
    private var cardsManager: IUserCardsStorageManager
    
    private var transManager: ITranslationsStorageManager
    
    init() {
        self.privateStack = CoreDataStack()
        self.userManager = AppUserStorageManager(stack: self.privateStack)
        self.dictManager = UserDictionaryStorageManager(stack: self.privateStack)
        self.cardsManager = UserCardStorageManager(stack: self.privateStack)
        self.transManager = UserTranslationStorageManager(stack: self.privateStack)
    }
}