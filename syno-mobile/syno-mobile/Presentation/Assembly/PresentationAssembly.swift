//
//  PresentationAssembly.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 23.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

protocol IPresentationAssembly {
    func loginViewController() -> LoginViewController
    
    func registerViewController() -> RegistrationViewController
    
    func dictsViewController() -> DictsViewController
    
    func mainTabBarController() -> CommonTabBarController
    
    func cardsViewController(sourceDict: DbUserDictionary) -> DictCardsController
    
    func translationsViewController(sourceCard: DbUserCard) -> TranslationsCollectionViewController
    
    func testAndLearnViewController() -> TestAndLearnViewController
    
    func learnController(sourceDict: DbUserDictionary) -> LearnCollectionViewController
    
    func testController(sourceDict: DbUserDictionary) -> TestViewController
    
    func startController() -> UIViewController
    
    func newCardController() -> NewOrEditCardController
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
        return TestAndLearnViewController(datasource: TestAndLearnDictionaryDataSource(viewModel: self.serviceAssembly.testAndLearnDictControllerDataProvider(), presAssembly: self))
    }
    
    func learnController(sourceDict: DbUserDictionary) -> LearnCollectionViewController {
        let viewModel = self.serviceAssembly.learnTranslationsControllerDataProvider(sourceDict: sourceDict)
        
        var views: [ILearnView] = []
        
        for i in 0..<viewModel.count {
            let ithDataSource = LearnControllerTableViewDataSource(viewModel: viewModel, state: LearnControllerState(itemNumber: i))
            views.append(LearnViewGenerator().generate(dataSource: ithDataSource, actionsDelegate: ithDataSource, scrollViewDelegate: nil))
            ithDataSource.delegate = views.last!
        }
        
        return LearnCollectionViewController(data: LearnViewControllerData(cardsAmount: viewModel.count, dictName: viewModel.dictName), learnViews: views)
    }
    
    func testController(sourceDict: DbUserDictionary) -> TestViewController {
        let cardsAmount = sourceDict.getCards().count
        var views: [ITestView] = []
        let answers = AnswersStorage(answers: Array.init(repeating: [], count: cardsAmount))
        
        for i in 0..<cardsAmount {
            let testView = TestView(model: serviceAssembly.testViewControllerModel(state: TestControllerState(itemNumber: i, answers: answers), dictionary: sourceDict))
            views.append(testView)
        }
        
        
        return TestViewController(testViews: views, dictName: sourceDict.name ?? "")
    }
    
    func startController() -> UIViewController {
        if (self.serviceAssembly.userAuthHelper.isAuthorized()) {
            //DEBUG TODO
            //return self.mainTabBarController()
            return self.loginViewController()
        } else {
            return self.loginViewController()
        }
    }
    
    func newCardController() -> NewOrEditCardController {
        return NewOrEditCardController()
    }
    
    init(serviceAssembly: IServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
}
