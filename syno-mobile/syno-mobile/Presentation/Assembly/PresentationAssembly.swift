import Foundation
import UIKit

/// Assembly protocol for creating ViewController with all needed dependencies
protocol IPresentationAssembly {
    /// Creates `LoginViewController`
    func loginViewController() -> LoginViewController
    
    /// Creates `RegistrationViewController`
    func registerViewController() -> RegistrationViewController
    
    /// Creates `DictsViewController`
    func dictsViewController() -> DictsViewController
    
    func accountConfirmationController() -> AccountConfirmationController
    
    func emailForConfirmationController() -> EmailForConfirmationController
    
    /// Creates `CommonTabBarController`
    func mainTabBarController() -> CommonTabBarController
    
    /// Creates `DictCardsController`
    /// - Parameter sourceDict: dictionary which cards to display
    func cardsViewController(sourceDict: DbUserDictionary) -> DictCardsController
    
    /// Creates `TranslationsCollectionViewController`
    /// - Parameter sourceCard: Card which translations to display
    func translationsViewController(sourceCard: DbUserCard) -> TranslationsCollectionViewController
    
    /// Creates `TestAndLearnViewController`
    func testAndLearnViewController() -> TestAndLearnViewController
    
    /// Creates `LearnCollectionViewController`
    /// - Parameter sourceDict: Dictionary which cards will be displayed
    func learnController(sourceDict: DbUserDictionary) -> LearnCollectionViewController
  
    func reversedLearnController(sourceDict: DbUserDictionary) -> ReversedLearnCollectionViewController
    
    /// Creates `TestViewController`
    /// - Parameter sourceDict: to `sourceDict` new test will be attached
    func testController(sourceDict: DbUserDictionary) -> TestViewController
    
    /// Gets controller that user will see first: `LoginViewController` or `DictsViewController`
    func startController() -> UIViewController
    
    /// Creates `NewOrEditCardController`
    /// - Parameter tempSourceCard: temporary source card that will be filled and saved or discarded
    func newCardController(tempSourceCard: DbUserCard) -> NewOrEditCardController
    
    /// Creates `NewDictController`
    func newDictController() -> UIViewController
    
    func editDictController(dictToEdit: DbUserDictionary) -> UIViewController
    
    /// Creates `TestResultsViewController`
    /// - Parameter sourceTest: test which results to present
    func testResultsController(sourceTest: DbUserTest) -> UIViewController
    
    /// Creates `HomeViewController`
    func homeController() -> UIViewController
    
    /// Creates `LoginFromHomeViewController`
    func loginFromHomeViewController() -> UIViewController
    
    /// Creates `AddShareViewController`
    func addShareController(uuid: String?) -> UIViewController
    
    func trashController() -> UIViewController
    
    func congratsController() -> UIViewController
}

class PresentationAssembly: IPresentationAssembly {
    func emailForConfirmationController() -> EmailForConfirmationController {
        return EmailForConfirmationController(model: self.serviceAssembly.emailConfirmationModel, presentationAssembly: self)
    }
    
    func accountConfirmationController() -> AccountConfirmationController {
        return AccountConfirmationController(model: self.serviceAssembly.confirmationModel)
    }
    
    /// Assembly for creating/getting services
    private let serviceAssembly: IServiceAssembly
    
    func loginViewController() -> LoginViewController {
        return LoginViewController(presAssembly: self, loginModel: LoginModel(loginService: serviceAssembly.loginService))
    }
    
    func registerViewController() -> RegistrationViewController {
        return RegistrationViewController(registerModel: self.serviceAssembly.registerModel, assembly: self)
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
  
    func reversedLearnController(sourceDict: DbUserDictionary) -> ReversedLearnCollectionViewController {
      let model = self.serviceAssembly.reversedLearnControllerModel(sourceDict: sourceDict)
      
      var views: [ReversedLearnView] = []
      
      for i in 0..<model.getCardsCount() {
        let view = ReversedLearnViewGenerator().generate(model: model, state: ReversedLearnView.State(cardNumber: i))
        views.append(view)
      }
      return ReversedLearnCollectionViewController(model: model, learnViews: views)
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
            return self.mainTabBarController()
            //return self.loginViewController()
            //return self.accountConfirmationController()
        } else {
            return self.loginViewController()
            //return self.accountConfirmationController()
        }
    }
    
    func newCardController(tempSourceCard: DbUserCard) -> NewOrEditCardController {
        return NewOrEditCardController(dataSource: TranslationControllerDataSource(viewModel: self.serviceAssembly.translationsControllerDataProvider(), sourceCard: tempSourceCard, phonemesManager: self.serviceAssembly.phonemesManager, isAutoPhonemesEnabled: true))
    }
    
    func newDictController() -> UIViewController {
        return NewDictController(model: self.serviceAssembly.newDictControllerModel)
    }
    
    func editDictController(dictToEdit: DbUserDictionary) -> UIViewController {
        return NewDictController(model: self.serviceAssembly.editDictControllerModel(dictToEdit: dictToEdit))
    }
    
    func testResultsController(sourceTest: DbUserTest) -> UIViewController {
        return TestResultsViewController(dataSource: self.serviceAssembly.testResultsControllerDataSource(sourceTest: sourceTest))
    }
    
    func homeController() -> UIViewController {
        return HomeViewController(dataProvider: self.serviceAssembly.homeControllerDataProvider(presAssembly: self))
    }
    
    func loginFromHomeViewController() -> UIViewController {
        return LoginFromHomeViewController(presAssembly: self, loginModel: LoginModel(loginService: serviceAssembly.loginService))
    }
    
    func addShareController(uuid: String?) -> UIViewController {
        return AddShareViewController(shareModel: self.serviceAssembly.addShareModel(), uuid: uuid)
    }
    
    func trashController() -> UIViewController {
        return DictsTrashViewController(datasource: self.serviceAssembly.trashDictionariesDataSource(presAssembly: self))
    }
    
    func congratsController() -> UIViewController {
        return CongratulationsController(model: self.serviceAssembly.congratulationsModel)
    }
    
    /**
     Creates new `PresentationAssembly`
     - Parameter serviceAssembly: Assembly for creating/getting services
     */
    init(serviceAssembly: IServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
}
