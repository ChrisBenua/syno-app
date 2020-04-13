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
    
    var phonemesManager: IPhonemesManager { get }
    
    var registerService: IRegisterService { get }
    
    var translationsFetchService: ITranslationFetchService { get }
    
    var cardsFetchService: IUserCardsFetchService { get }
    
    var dictsFetchService: IUserDictionaryFetchService { get }
    
    var userAuthHelper: IUserAuthHelper { get }
    
    var dictionaryControllerDataProvider: IDictionaryControllerDataProvider { get }
    
    var newDictControllerModel: INewDictControllerModel { get }
        
    func dictControllerModel() -> DictControllerModel
    
    func cardsControllerDataProvider() -> ICardsControllerDataProvider
    
    func translationsControllerDataProvider() -> ITranslationControllerDataProvider
    
    func testAndLearnDictControllerDataProvider() -> IDictionaryControllerDataProvider
    
    func learnTranslationsControllerDataProvider(sourceDict: DbUserDictionary) -> ILearnControllerDataProvider
    
    func testViewControllerDataProvider(dictionary: DbUserDictionary) -> ITestViewControllerDataProvider
    
    func testViewControllerDatasource(state: ITestControllerState, dictionary: DbUserDictionary) -> ITestViewControllerDataSource
    
    func testViewControllerModel(state: ITestControllerState, dictionary: DbUserDictionary) -> ITestViewControllerModel
    
    func testResultsControllerDataProvider(sourceTest: DbUserTest) -> ITestResultsControllerDataProvider
    
    func testResultsControllerDataSource(sourceTest: DbUserTest) -> ITestResultsControllerDataSource
}

class ServiceAssembly: IServiceAssembly {
    var newDictControllerModel: INewDictControllerModel
    
    private let coreAssembly: ICoreAssembly
    
    var phonemesManager: IPhonemesManager {
        get {
            coreAssembly.phonemesManager
        }
    }
    
    var loginService: ILoginService
    
    var registerService: IRegisterService
    
    var translationsFetchService: ITranslationFetchService
    
    var cardsFetchService: IUserCardsFetchService
    
    var userAuthHelper: IUserAuthHelper
    
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
        self.userAuthHelper = UserAuthHelper(userDefManager: coreAssembly.userDefaultsManager)
        self.newDictControllerModel = NewDictControllerModel(storageManager: coreAssembly.storageManager)
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
    
    func testViewControllerDataProvider(dictionary: DbUserDictionary) -> ITestViewControllerDataProvider {
        return TestViewControllerDataProvider(sourceDictionary: dictionary, storageManager: self.coreAssembly.storageManager)
    }
    
    func testViewControllerDatasource(state: ITestControllerState, dictionary: DbUserDictionary) -> ITestViewControllerDataSource {
        return TestViewControllerDataSource(state: state, dataProvider: testViewControllerDataProvider(dictionary: dictionary))
    }
    
    func testViewControllerModel(state: ITestControllerState, dictionary: DbUserDictionary) -> ITestViewControllerModel {
        return TestViewControllerModel(dataSource: testViewControllerDatasource(state: state, dictionary: dictionary))
    }
    
    func testResultsControllerDataProvider(sourceTest: DbUserTest) -> ITestResultsControllerDataProvider {
        return TestResultsControllerDataProvider(test: sourceTest)
    }
    
    func testResultsControllerDataSource(sourceTest: DbUserTest) -> ITestResultsControllerDataSource {
        let dataProvider = testResultsControllerDataProvider(sourceTest: sourceTest)
        return TestResultsControllerDataSource(dataProvider: dataProvider, state: TestResultsControllerState(withDefaultSize: dataProvider.totalCards()))
    }
}
