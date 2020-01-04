//
//  ServiceAssembly.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IServiceAssembly {
    var loginService: ILoginService { get }
    
    var registerService: IRegisterService { get }
    
    var translationsFetchService: ITranslationFetchService { get }
    
    var cardsFetchService: IUserCardsFetchService { get }
    
    var dictsFetchService: IUserDictionaryFetchService { get }
    
    var dictionaryControllerDataProvider: IDictionaryControllerDataProvider { get }
        
    func dictControllerModel() -> DictControllerModel
    
    func cardsControllerDataProvider() -> ICardsControllerDataProvider
    
    func translationsControllerDataProvider() -> ITranslationControllerDataProvider
    
    func testAndLearnDictControllerDataProvider() -> IDictionaryControllerDataProvider
    
    func learnTranslationsControllerDataProvider(sourceDict: DbUserDictionary) -> ILearnControllerDataProvider
}

class ServiceAssembly: IServiceAssembly {
    private let coreAssembly: ICoreAssembly
    
    var loginService: ILoginService
    
    var registerService: IRegisterService
    
    var translationsFetchService: ITranslationFetchService
    
    var cardsFetchService: IUserCardsFetchService
    
    var dictsFetchService: IUserDictionaryFetchService
    
    var dictionaryControllerDataProvider: IDictionaryControllerDataProvider
    
    var innerBatchUpdatesQueue: DispatchQueue = DispatchQueue(label: "innerCoreDataDispatchQueue")
    
    
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
        self.loginService = LoginService(storageManager: self.coreAssembly.storageManager, requestSender: coreAssembly.requestSender, userDefaultsManager: coreAssembly.userDefaultsManager)
        self.registerService = RegisterService(requestSender: coreAssembly.requestSender)
        self.translationsFetchService = DbTranslationFetchService(innerQueue: innerBatchUpdatesQueue,storageManager: coreAssembly.storageManager)
        self.cardsFetchService = UserCardsFetchService(innerQueue: innerBatchUpdatesQueue,storageManager: coreAssembly.storageManager, translationsFetchService: self.translationsFetchService)
        self.dictsFetchService = UserDictsFetchService(innerQueue: innerBatchUpdatesQueue,storageManager: coreAssembly.storageManager, cardsFetchService: self.cardsFetchService)
        self.dictionaryControllerDataProvider = DictionaryControllerDataProvider(appUserManager: self.coreAssembly.storageManager)
    }
    
    func dictControllerModel() -> DictControllerModel {
        return DictControllerModel(userDictsFetchService: dictsFetchService, sender: self.coreAssembly.requestSender, userDefManager: self.coreAssembly.userDefaultsManager, appUserManager: self.coreAssembly.storageManager)
    }
    
    func cardsControllerDataProvider() -> ICardsControllerDataProvider {
        return CardsControllerDataProvider(storageCoordinator: self.coreAssembly.storageManager)
    }
    
    func translationsControllerDataProvider() -> ITranslationControllerDataProvider {
        return TranslationControllerDataProvider(storageCoordinator: self.coreAssembly.storageManager)
    }
    
    func testAndLearnDictControllerDataProvider() -> IDictionaryControllerDataProvider {
        return DictionaryControllerDataProvider(appUserManager: self.coreAssembly.storageManager)
    }
    
    func learnTranslationsControllerDataProvider(sourceDict: DbUserDictionary) -> ILearnControllerDataProvider {
        return LearnControllerDataProvider(dbUserDict: sourceDict)
    }
}
