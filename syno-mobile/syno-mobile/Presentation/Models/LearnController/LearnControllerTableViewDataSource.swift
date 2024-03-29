import Foundation
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
    /// Total amount of cards
    var count: Int { get }
    /// Dictionary name
    var dictName: String? { get }
}

class LearnControllerDataProvider: ILearnControllerDataProvider {
    func getTranslatedWord(cardPos: Int) -> String? {
        return translatedWords[cardPos]
    }
    
    func getItem(cardPos: Int, transPos: Int) -> UserTranslationDtoForLearnController {
        return itemsInCards[cardPos][transPos]
    }
    
    func getItems(currCardPos: Int) -> [UserTranslationDtoForLearnController] {
        return itemsInCards[currCardPos]
    }
    
    var count: Int {
        get {
            return itemsInCards.count
        }
    }
    /// `UserTranslationDtoForLearnController` storage
    private var itemsInCards: [[UserTranslationDtoForLearnController]]
    /// Translated words for each card
    private var translatedWords: [String?]
    
    var dictName: String?
    
    /**
     Creates new ``
     - Parameter dbUserDict: `DbUserDictionary` to create learn controller for
     */
    init(dbUserDict: DbUserDictionary) {
        self.dictName = dbUserDict.name
        let cards = dbUserDict.getCards().shuffled()
        self.translatedWords = cards.map({ (card) -> String? in
            card.translatedWord
        })
        self.itemsInCards = cards.map({ (card) -> [UserTranslationDtoForLearnController] in
            return card.getTranslations().reversed().map { (trans) -> UserTranslationDtoForLearnController in
                return UserTranslationDtoForLearnController.initFrom(translation: trans)
            }
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
}

/// Protocol for view's interaction with `ILearnControllerTableViewDataSource`
protocol ILearnControllerActionsDelegate: class {
    /// Shows one new translation
    func onPlusOne()
    /// Shows all translation
    func onShowAll()
}

/// `ILearnControllerTableViewDataSource` event handler
protocol ILearnControllerDataSourceReactor: class {
    /// adds new rows to table view
    func addItems(indexPaths: [IndexPath])
}

class LearnControllerTableViewDataSource: NSObject, ILearnControllerTableViewDataSource {
    
    weak var delegate: ILearnControllerDataSourceReactor?
    
    var viewModel: ILearnControllerDataProvider
    
    var state: ILearnControllerState
    
    var didAddNew: Bool = false
    
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
        return state.translationsShown
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TranslationReadonlyTableViewCell.cellId(), for: indexPath) as? TranslationReadonlyTableViewCell else {
            fatalError()
        }
        let transDto = self.viewModel.getItem(cardPos: self.state.itemNumber, transPos: self.state.translationsShown - indexPath.row - 1)
        
        cell.setup(config: TranslationCellConfiguration(translation: transDto.translation, transcription: transDto.transcription, comment: transDto.comment, sample: transDto.sample))
        
        return cell
    }
    
    /**
     Creates new `LearnControllerTableViewDataSource` with default state
     - Parameter viewModel: data delivery service
     */
    init(viewModel: ILearnControllerDataProvider) {
        self.viewModel = viewModel
        self.state = LearnControllerState()
    }
    
    /**
    Creates new `LearnControllerTableViewDataSource` with given state
    - Parameter viewModel: data delivery service
    - Parameter state: given state
    */
    init(viewModel: ILearnControllerDataProvider, state: ILearnControllerState) {
        self.viewModel = viewModel
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
}
