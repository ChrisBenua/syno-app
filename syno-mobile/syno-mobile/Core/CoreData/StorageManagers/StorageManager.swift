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
    func createAppUser(email: String, password: String)
    
    func markAppUserAsCurrent(user: DbAppUser)
}

protocol IUserDictionaryStorageManager {
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, cards: [DbUserCard]?)
}

protocol IUserCardsStorageManager {
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, language: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?)
}

protocol ITranslationsStorageManager {
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, timeCreated: Date?, timeModified: Date?)
}

protocol IStorageCoordinator: IAppUserStorageManager, IUserDictionaryStorageManager, IUserCardsStorageManager, ITranslationsStorageManager {
    static var shared: IStorageCoordinator { get }
       
    func performSave(in context: NSManagedObjectContext)
}

class StorageManager: IStorageCoordinator {
    func performSave(in context: NSManagedObjectContext) {
        DispatchQueue.global(qos: .background).async {
            self.stack.performSave(with: context, completion: nil)
        }
    }
    
    func createAppUser(email: String, password: String) {
        self.userManager.createAppUser(email: email, password: password)
    }
    
    func markAppUserAsCurrent(user: DbAppUser) {
        self.userManager.markAppUserAsCurrent(user: user)
    }
    
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, cards: [DbUserCard]?) {
        self.dictManager.createUserDictionary(owner: owner, name: name, timeCreated: timeCreated, timeModified: timeModified, serverId: serverId, cards: cards)
    }
    
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, language: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?) {
        self.cardsManager.createUserCard(sourceDict: sourceDict, translatedWord: translatedWord, language: language, timeCreated: timeCreated, timeModified: timeModified, serverId: serverId, translation: translation)
    }
    
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, timeCreated: Date?, timeModified: Date?) {
        self.transManager.createTranslation(sourceCard: sourceCard, usageSample: usageSample, translation: translation, transcription: transcription, comment: comment, timeCreated: timeCreated, timeModified: timeModified)
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
