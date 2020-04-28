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
    
    func newCardController(tempSourceCard: DbUserCard) -> NewOrEditCardController
    
    func newDictController() -> UIViewController
    
    func testResultsController(sourceTest: DbUserTest) -> UIViewController
    
    func homeController() -> UIViewController
    
    func loginFromHomeViewController() -> UIViewController
    
    func addShareController() -> UIViewController
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
        return DictsViewController(datasource: DictionaryControllerTableViewDataSource(viewModel: self.serviceAssembly.dictionaryControllerDataProvider, shareService: self.serviceAssembly.dictShareService, presAssembly: self), model: serviceAssembly.dictControllerModel())
    }
    
    func cardsViewController(sourceDict: DbUserDictionary) -> DictCardsController {
        return DictCardsController(dataSource: CardsControllerDataSource(viewModel: self.serviceAssembly.cardsControllerDataProvider(), sourceDict: sourceDict), presAssembly: self)
    }
    
    func translationsViewController(sourceCard: DbUserCard) -> TranslationsCollectionViewController {
        return TranslationsCollectionViewController(dataSource: TranslationControllerDataSource(viewModel: self.serviceAssembly.translationsControllerDataProvider(), sourceCard: sourceCard, phonemesManager: self.serviceAssembly.phonemesManager, isAutoPhonemesEnabled: true))
    }
    
    func mainTabBarController() -> CommonTabBarController {
        return CommonTabBarController(presentationAssembly: self)
    }
    
    func testAndLearnViewController() -> TestAndLearnViewController {
        return TestAndLearnViewController(datasource: TestAndLearnDictionaryDataSource(viewModel: self.serviceAssembly.testAndLearnDictControllerDataProvider(), presAssembly: self, recentTestsDataSource: self.serviceAssembly.recentTestsDataSource()))
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
        let dataProvider = serviceAssembly.testViewControllerDataProvider(dictionary: sourceDict)
        for i in 0..<cardsAmount {
            let testView = TestView(model: serviceAssembly.testViewControllerModel(state: TestControllerState(itemNumber: i, answers: answers), dictionary: sourceDict, dataProvider: dataProvider))
            views.append(testView)
        }
        
        
        return TestViewController(testViews: views, dictName: sourceDict.name ?? "", presAssembly: self)
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
    
    func newCardController(tempSourceCard: DbUserCard) -> NewOrEditCardController {
        return NewOrEditCardController(dataSource: TranslationControllerDataSource(viewModel: self.serviceAssembly.translationsControllerDataProvider(), sourceCard: tempSourceCard, phonemesManager: self.serviceAssembly.phonemesManager, isAutoPhonemesEnabled: true))
    }
    
    func newDictController() -> UIViewController {
        return NewDictController(model: self.serviceAssembly.newDictControllerModel)
    }
    
    func testResultsController(sourceTest: DbUserTest) -> UIViewController {
        return TestResultsViewController(dataSource: self.serviceAssembly.testResultsControllerDataSource(sourceTest: sourceTest))
    }
    
    func homeController() -> UIViewController {
        return HomeViewController(dataProvider: self.serviceAssembly.homeControllerDataProvider(presAssembly: self))
    }
    
    func loginFromHomeViewController() -> UIViewController {
        return LoginFromHomeViewController(presAssembly: self, loginModel: LoginModel(loginService: serviceAssembly.loginService), registrationViewController: registerViewController())
    }
    
    func addShareController() -> UIViewController {
        return AddShareViewController(shareModel: self.serviceAssembly.addShareModel())
    }
    
    init(serviceAssembly: IServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
}
