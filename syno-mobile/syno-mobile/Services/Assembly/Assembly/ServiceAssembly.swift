import Foundation

/// Protocol with all services dependencies
protocol IServiceAssembly {
    /// Service for performing authorization
    var loginService: ILoginService { get }
    
    /// Service responsible for generating transcriptions
    var phonemesManager: IPhonemesManager { get }
    
    /// Service responsible for performing registration
    var registerService: IRegisterService { get }
    
    /// Service responsible for updating/creating `DbTranslation` instances
    var translationsFetchService: ITranslationFetchService { get }
    
    /// Service responsible for updating/creating `DbUserCard` instances
    var cardsFetchService: IUserCardsFetchService { get }
    
    /// Service responsible for updating/creating `DbUserDictionary` instances
    var dictsFetchService: IUserDictionaryFetchService { get }
    
    /// Service responsible for validating user token
    var userAuthHelper: IUserAuthHelper { get }
    
    /// Service responsible for delivering data to DictionaryController
    var dictionaryControllerDataProvider: IDictionaryControllerDataProvider { get }
    
    /// Service responsible for inner logic inside NewDictionaryController
    var newDictControllerModel: INewDictControllerModel { get }
    
    /// Service responsible for sharing dictionaries
    var dictShareService: IDictShareService { get }
    
    var registerModel: IRegistrationModel { get }
    
    var emailConfirmationModel: IEmailConfirmationModel { get }
    
    var updateRequestDataPreparator: IUpdateRequestDataPreprator { get }
    
    var confirmationModel: IAccountConfirmationModel { get }
     
    /// Service responsible for inner logic in DictionaryController
    func dictControllerModel() -> DictControllerModel
    
    /// Service responsible for delivering data to CardsController
    func cardsControllerDataProvider() -> ICardsControllerDataProvider
    
    /// Service responsible for delivering data to TranslationsController
    func translationsControllerDataProvider() -> ITranslationControllerDataProvider
    
    /// Service responsible for delivering data for DictionaryController
    func testAndLearnDictControllerDataProvider() -> IDictionaryControllerDataProvider
    
    /// Service responsible for delivering data for LearnController
    func learnTranslationsControllerDataProvider(sourceDict: DbUserDictionary) -> ILearnControllerDataProvider
    
    /// Service responsible for delivering data for TestController
    func testViewControllerDataProvider(dictionary: DbUserDictionary) -> ITestViewControllerDataProvider
    
    /// Service responsible for data formatting for TestController
    func testViewControllerDatasource(state: ITestControllerState, dictionary: DbUserDictionary, dataProvider: ITestViewControllerDataProvider?) -> ITestViewControllerDataSource
    
    /// Service responsible for inner logic in TestController
    func testViewControllerModel(state: ITestControllerState, dictionary: DbUserDictionary, dataProvider: ITestViewControllerDataProvider?) -> ITestViewControllerModel
    
    /// Service responsible for delivering data to TestResultsController
    func testResultsControllerDataProvider(sourceTest: DbUserTest) -> ITestResultsControllerDataProvider
    
    /// Service responsible for data formatting for TestResultsController
    func testResultsControllerDataSource(sourceTest: DbUserTest) -> ITestResultsControllerDataSource
    
    /// Service responsible for delivering data to RecentTestsView
    func recentTestsDataProvider() -> IRecentTestsDataProvider
    
    /// Service responsible for data formatting for RecentTestsView
    func recentTestsDataSource() -> IRecentTestsDataSource
    
    /// Service responsible for inner logic in HomeController
    func homeControllerDataProvider(presAssembly: IPresentationAssembly) -> IHomeControllerMenuDataProvider
    
    /// Service  responsible for inner logic in AddShareController
    func addShareModel() -> IAddShareModel
    
    /// Service responsible for creating copy on server
    var updateRequestService: IUpdateRequestService { get }
    
    var transferService: ITransferGuestDictsToNewAccount { get }
}

/// Provides all services realizations
class ServiceAssembly: IServiceAssembly {
    var newDictControllerModel: INewDictControllerModel
    
    private let coreAssembly: ICoreAssembly
    
    var phonemesManager: IPhonemesManager {
        get {
            coreAssembly.phonemesManager
        }
    }
    
    var registerModel: IRegistrationModel
    
    var updateRequestService: IUpdateRequestService
    
    var loginService: ILoginService
    
    var registerService: IRegisterService
    
    var confirmationModel: IAccountConfirmationModel
    
    var emailConfirmationModel: IEmailConfirmationModel
    
    var updateRequestDataPreparator: IUpdateRequestDataPreprator
    
    var translationsFetchService: ITranslationFetchService
    
    var transferService: ITransferGuestDictsToNewAccount
    
    var cardsFetchService: IUserCardsFetchService
    
    var userAuthHelper: IUserAuthHelper
    
    var dictsFetchService: IUserDictionaryFetchService
    
    var dictionaryControllerDataProvider: IDictionaryControllerDataProvider
    
    var dictShareService: IDictShareService
    
    var innerBatchUpdatesQueue: DispatchQueue = DispatchQueue(label: "innerCoreDataDispatchQueue", attributes: .concurrent)
    
    var innerBatchUpdatesQueue1: DispatchQueue = DispatchQueue(label: "innerCoreDataDispatchQueue1", attributes: .concurrent)
    
    var innerBatchUpdatesQueue2: DispatchQueue = DispatchQueue(label: "innerCoreDataDispatchQueue2", attributes: .concurrent)
    
    
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
        self.loginService = LoginService(storageManager: self.coreAssembly.storageManager, requestSender: coreAssembly.requestSender, userDefaultsManager: coreAssembly.userDefaultsManager)
        self.registerService = RegisterService(requestSender: coreAssembly.requestSender)
        self.translationsFetchService = DbTranslationFetchService(innerQueue: innerBatchUpdatesQueue,storageManager: coreAssembly.storageManager)
        self.cardsFetchService = UserCardsFetchService(innerQueue: innerBatchUpdatesQueue1,storageManager: coreAssembly.storageManager, translationsFetchService: self.translationsFetchService)
        self.dictsFetchService = UserDictsFetchService(innerQueue: innerBatchUpdatesQueue2,storageManager: coreAssembly.storageManager, cardsFetchService: self.cardsFetchService)
        self.dictionaryControllerDataProvider = DictionaryControllerDataProvider(appUserManager: self.coreAssembly.storageManager)
        self.userAuthHelper = UserAuthHelper(userDefManager: coreAssembly.userDefaultsManager)
        self.newDictControllerModel = NewDictControllerModel(storageManager: coreAssembly.storageManager)
        self.updateRequestDataPreparator = UpdateRequestDataPreprator(storageManager: self.coreAssembly.storageManager)
        self.updateRequestService = UpdateRequestService(dataPreparator: updateRequestDataPreparator, sender: self.coreAssembly.requestSender, userDefaultsManager: self.coreAssembly.userDefaultsManager)
        self.dictShareService = DictShareService(userDefManager: self.coreAssembly.userDefaultsManager, requestSender: self.coreAssembly.requestSender, storageManager: self.coreAssembly.storageManager, dictsFetchService: self.dictsFetchService)
        self.registerModel =  RegistrationModel(registerService: self.registerService, userDefaultsManager: self.coreAssembly.userDefaultsManager)
        self.confirmationModel = AccountConfirmationModel(userDefaultsManager: self.coreAssembly.userDefaultsManager, requestSender: self.coreAssembly.requestSender)
        self.emailConfirmationModel = EmailConfirmationModel(requestSender: self.coreAssembly.requestSender, userDefaultsManager: self.coreAssembly.userDefaultsManager)
        self.transferService = TransferGuestDictsToNewAccount(storageManager: self.coreAssembly.storageManager, dictionaryFetchService: self.dictsFetchService)
    }
    
    func dictControllerModel() -> DictControllerModel {
        return DictControllerModel(userDictsFetchService: dictsFetchService, sender: self.coreAssembly.requestSender, userDefManager: self.coreAssembly.userDefaultsManager, appUserManager: self.coreAssembly.storageManager, transferService: self.transferService)
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
    
    func testViewControllerDatasource(state: ITestControllerState, dictionary: DbUserDictionary, dataProvider: ITestViewControllerDataProvider? = nil) -> ITestViewControllerDataSource {
        return TestViewControllerDataSource(state: state, dataProvider: dataProvider ?? testViewControllerDataProvider(dictionary: dictionary))
    }
    
    func testViewControllerModel(state: ITestControllerState, dictionary: DbUserDictionary, dataProvider: ITestViewControllerDataProvider?) -> ITestViewControllerModel {
        return TestViewControllerModel(dataSource: testViewControllerDatasource(state: state, dictionary: dictionary, dataProvider: dataProvider))
    }
    
    func testResultsControllerDataProvider(sourceTest: DbUserTest) -> ITestResultsControllerDataProvider {
        return TestResultsControllerDataProvider(test: sourceTest)
    }
    
    func testResultsControllerDataSource(sourceTest: DbUserTest) -> ITestResultsControllerDataSource {
        let dataProvider = testResultsControllerDataProvider(sourceTest: sourceTest)
        return TestResultsControllerDataSource(dataProvider: dataProvider, state: TestResultsControllerState(withDefaultSize: dataProvider.totalCards()))
    }
    
    func recentTestsDataProvider() -> IRecentTestsDataProvider {
        return RecentTestsDataProvider(storageManager: self.coreAssembly.storageManager)
    }
    
    func recentTestsDataSource() -> IRecentTestsDataSource {
        return RecentTestsDataSource(viewModel: self.recentTestsDataProvider())
    }
    
    func addShareModel() -> IAddShareModel {
        return AddShareModel(shareService: self.dictShareService)
    }
    
    func homeControllerDataProvider(presAssembly: IPresentationAssembly) -> IHomeControllerMenuDataProvider {
        return HomeControllerMenuDataProvider(presAssembly: presAssembly, dictControllerModel: self.dictControllerModel(), currentUserManager: self.coreAssembly.storageManager, updateService: self.updateRequestService, transferService: self.transferService)
    }
}
