//
//  PresentationAssembly.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 23.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IPresentationAssembly {
    func loginViewController() -> LoginViewController
    
    func registerViewController() -> RegistrationViewController
    
    func dictsViewController() -> DictsViewController
    
    func mainTabBarController() -> CommonTabBarController
    
    func cardsViewController(sourceDict: DbUserDictionary) -> DictCardsController
    
    func translationsViewController(sourceCard: DbUserCard) -> TranslationsCollectionViewController
    
    func testAndLearnViewController() -> TestAndLearnViewController
}

class PresentationAssembly: IPresentationAssembly {
    
    private let serviceAssembly: IServiceAssembly
    
    func loginViewController() -> LoginViewController {
        return LoginViewController(presAssembly: self, loginModel: LoginModel(loginService: serviceAssembly.loginService), registrationViewController: registerViewController())
    }
    
    func registerViewController() -> RegistrationViewController {
        return RegistrationViewController(registerModel: RegistrationModel(registerService: self.serviceAssembly.registerService))
    }
    
    func dictsViewController() -> DictsViewController {
        return DictsViewController(datasource: DictionaryControllerTableViewDataSource(viewModel: self.serviceAssembly.dictionaryControllerDataProvider, presAssembly: self), model: serviceAssembly.dictControllerModel())
    }
    
    func cardsViewController(sourceDict: DbUserDictionary) -> DictCardsController {
        return DictCardsController(dataSource: CardsControllerDataSource(viewModel: self.serviceAssembly.cardsControllerDataProvider(), sourceDict: sourceDict), presAssembly: self)
    }
    
    func translationsViewController(sourceCard: DbUserCard) -> TranslationsCollectionViewController {
        return TranslationsCollectionViewController(dataSource: TranslationControllerDataSource(viewModel: self.serviceAssembly.translationsControllerDataProvider(), sourceCard: sourceCard))
    }
    
    func mainTabBarController() -> CommonTabBarController {
        return CommonTabBarController(presentationAssembly: self)
    }
    
    func testAndLearnViewController() -> TestAndLearnViewController {
        return TestAndLearnViewController(datasource: TestAndLearnDictionaryDataSource(viewModel: self.serviceAssembly.testAndLearnDictControllerDataProvider()))
    }
    
    
    init(serviceAssembly: IServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
}
