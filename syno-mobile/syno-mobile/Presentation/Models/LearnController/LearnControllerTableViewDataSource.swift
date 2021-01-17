import Foundation
import CoreData
import UIKit

/// Protocol for storing user progress in `LearnController`
protocol ILearnControllerState {
    /// current card index
    var itemNumber: Int { get set }
    /// Number of translations shown
    var translationsShown: Int { get set }
}

class LearnControllerState: ILearnControllerState {
    private var _itemNumber: Int = 0
    var translationsShown: Int = 0
    
    init() {
        _itemNumber = 0
    }
    
    init(itemNumber: Int) {
        self._itemNumber = itemNumber
    }
    
    var itemNumber: Int {
        get {
            _itemNumber
        }
        set {
            _itemNumber = newValue
            translationsShown = 0
        }
    }
}

/// Protocol for delivering data to `LearnController`
protocol ILearnControllerDataProvider {
    /// Gets Translation dto for given card
    func getItem(cardPos: Int, transPos: Int) -> UserTranslationDtoForLearnController
    /// Gets translations dtos for given card
    func getItems(currCardPos: Int) -> [UserTranslationDtoForLearnController]
    /// Gets translated word for given card
    func getTranslatedWord(cardPos: Int) -> String?
    
    func getDbCard(currCardPos: Int) -> DbUserCard?
    
    func updateCard(currCardPos: Int)
    
    /// Total amount of cards
    var count: Int { get }
    /// Dictionary name
    var dictName: String? { get }
    
    var translationsLanguage: String? { get }
}

class LearnControllerDataProvider: ILearnControllerDataProvider {
    
    func getTranslatedWord(cardPos: Int) -> String? {
        return translatedWords[cardPos]
    }
    
    func getItem(cardPos: Int, transPos: Int) -> UserTranslationDtoForLearnController {
        return itemsInCards[cardPos].translations[transPos]
    }
    
    func getItems(currCardPos: Int) -> [UserTranslationDtoForLearnController] {
        return itemsInCards[currCardPos].translations
    }
    
    func getDbCard(currCardPos: Int) -> DbUserCard? {
        var card: DbUserCard? = nil
        storageManager.stack.mainContext.performAndWait {
            card = storageManager.stack.mainContext.object(with: itemsInCards[currCardPos].cardManagedObjectId) as? DbUserCard
        }
        return card
    }
    
    func updateCard(currCardPos: Int) {
        var card: DbUserCard? = nil
        storageManager.stack.mainContext.performAndWait {
            card = storageManager.stack.mainContext.object(with: itemsInCards[currCardPos].cardManagedObjectId) as? DbUserCard
        }
        if let card = card {
            self.itemsInCards[currCardPos] = UserCardDtoForLearnController.initFrom(userCard: card)
            self.translatedWords[currCardPos] = card.translatedWord ?? ""
        }
    }
    
    var count: Int {
        get {
            return itemsInCards.count
        }
    }
    /// `UserTranslationDtoForLearnController` storage
    private var itemsInCards: [UserCardDtoForLearnController]//UserCardDtoForLearnController
    /// Translated words for each card
    private var translatedWords: [String?]
    
    private var storageManager: IStorageCoordinator
    
    private var dictionaryObjectId: NSManagedObjectID
        
    var dictName: String?
    
    var translationsLanguage: String?
    
    /**
     Creates new ``
     - Parameter dbUserDict: `DbUserDictionary` to create learn controller for
     */
    init(dbUserDict: DbUserDictionary, storeManager: IStorageCoordinator) {
        self.dictionaryObjectId = dbUserDict.objectID
        self.dictName = dbUserDict.name
        self.storageManager = storeManager
        let cards = dbUserDict.getCards().shuffled()
        
        self.translationsLanguage = dbUserDict.getTranslationsLanguage()
        
        self.translatedWords = cards.map({ (card) -> String? in
            card.translatedWord
        })
        self.itemsInCards = cards.map({ (card) -> UserCardDtoForLearnController in
            return UserCardDtoForLearnController.initFrom(userCard: card)
        })
    }
}

/// Protocol for filling table view
protocol ILearnControllerTableViewDataSource: UITableViewDataSource, UITableViewDelegate, ILearnControllerActionsDelegate {
    /// Data delivery service
    var viewModel: ILearnControllerDataProvider { get }
    /// Current state
    var state: ILearnControllerState { get }
    /// event handler
    var delegate: ILearnControllerDataSourceReactor? { get set }
    
    func refreshData()
}

/// Protocol for view's interaction with `ILearnControllerTableViewDataSource`
protocol ILearnControllerActionsDelegate: class {
    /// Shows one new translation
    func onPlusOne()
    /// Shows all translation
    func onShowAll()
    
    func showEditCardController()
}

/// `ILearnControllerTableViewDataSource` event handler
protocol ILearnControllerDataSourceReactor: class {
    /// adds new rows to table view
    func addItems(indexPaths: [IndexPath])
    
    func showController(controller: UIViewController)
    
    func onUpdateWholeView()
}

class LearnControllerTableViewDataSource: NSObject, ILearnControllerTableViewDataSource {
    private var presentationAssembly: IPresentationAssembly
    
    weak var delegate: ILearnControllerDataSourceReactor?
    
    var viewModel: ILearnControllerDataProvider
    
    var state: ILearnControllerState
    
    var didAddNew: Bool = false
    
    var translationsShown: Int {
        return min(state.translationsShown, viewModel.getItems(currCardPos: self.state.itemNumber).count)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && didAddNew {
            let myCell = cell as! TranslationReadonlyTableViewCell
            didAddNew = false
            myCell.innerView.baseShadowView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                myCell.innerView.baseShadowView.alpha = 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.state.translationsShown = translationsShown
        return translationsShown
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TranslationReadonlyTableViewCell.cellId(), for: indexPath) as? TranslationReadonlyTableViewCell else {
            fatalError()
        }
        let transDto = self.viewModel.getItem(cardPos: self.state.itemNumber, transPos: self.translationsShown - indexPath.row - 1)
        
        cell.setup(config: TranslationCellConfiguration(translation: transDto.translation, transcription: transDto.transcription, comment: transDto.comment, sample: transDto.sample, translationsLanguage: viewModel.translationsLanguage))
        
        return cell
    }
    
    /**
     Creates new `LearnControllerTableViewDataSource` with default state
     - Parameter viewModel: data delivery service
     */
    init(viewModel: ILearnControllerDataProvider, presentationAssembly: IPresentationAssembly) {
        self.viewModel = viewModel
        self.presentationAssembly = presentationAssembly
        self.state = LearnControllerState()
    }
    
    /**
    Creates new `LearnControllerTableViewDataSource` with given state
    - Parameter viewModel: data delivery service
    - Parameter state: given state
    */
    init(viewModel: ILearnControllerDataProvider, state: ILearnControllerState, presentationAssembly: IPresentationAssembly) {
        self.viewModel = viewModel
        self.presentationAssembly = presentationAssembly
        self.state = state
    }
    
    func onPlusOne() {
        if (self.state.translationsShown < self.viewModel.getItems(currCardPos: self.state.itemNumber).count) {
            self.state.translationsShown += 1
            didAddNew = true
            self.delegate?.addItems(indexPaths: [IndexPath(row: 0, section: 0)])
        }
    }
    
    func onShowAll() {
        let items = (0..<self.viewModel.getItems(currCardPos: self.state.itemNumber).count - self.state.translationsShown).map { (row) -> IndexPath in
            return IndexPath(row: row, section: 0)
        }
        didAddNew = true
        self.state.translationsShown = self.viewModel.getItems(currCardPos: self.state.itemNumber).count
        delegate?.addItems(indexPaths: items)
    }
    
    func showEditCardController() {
        if let card = self.viewModel.getDbCard(currCardPos: self.state.itemNumber) {
            let controller = presentationAssembly.translationsViewController(sourceCard: card)
            self.delegate?.showController(controller: controller)
        }
    }
    
    func refreshData() {
        self.viewModel.updateCard(currCardPos: self.state.itemNumber)
        self.delegate?.onUpdateWholeView()
    }
}
