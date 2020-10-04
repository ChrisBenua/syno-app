import Foundation
import UIKit

/// Dto for user input in `TestViewController`
protocol ITestControllerAnswer {
    /// User's answer
    var answer: String { get set }
}

class TestControllerAnswer: ITestControllerAnswer {
    var answer: String
    
    /**
     Creates new `TestControllerAnswer`
     - Parameter answer: user's answer
     */
    init(answer: String) {
        self.answer = answer
    }
}

/// Wrapper for storing all user's answers
class AnswersStorage {
    /// Actual user's answers
    var answers: [[ITestControllerAnswer]]
    
    /// Gets `index` card answers
    subscript(index: Int) -> [ITestControllerAnswer] {
        return answers[index]
    }
    
    /// Gets `index2` user's answer in `index1` card
    subscript(index1: Int, index2: Int) -> ITestControllerAnswer {
        return answers[index1][index2]
    }
    
    /// Adds new answer
    func append(pos: Int, answer: ITestControllerAnswer) {
        self.answers[pos].append(answer)
    }
    
    /// Removes answer
    func remove(pos1: Int, pos2: Int) {
        self.answers[pos1].remove(at: pos2)
    }
    
    /// Updates answer for card at `pos1`
    func setAnswer(pos1: Int, pos2: Int, answer: String) {
        self.answers[pos1][pos2].answer = answer
    }
    
    /**
     Creates new `AnswersStorage`:
     - Parameter answers: initial answers
     */
    init(answers: [[ITestControllerAnswer]]) {
        self.answers = answers
    }
}

/// Protocol for storing `ITestViewControllerDataSource` state
protocol ITestControllerState {
    /// Current card number
    var itemNumber: Int { get set }
    /// User's answers
    var answers: AnswersStorage { get set }
}

class TestControllerState: ITestControllerState {
    var itemNumber: Int
    
    var answers: AnswersStorage
    
    /**
     Creates new default `TestControllerState`
     */
    init() {
        itemNumber = 0
        answers = AnswersStorage(answers: [])
    }
    
    /**
     Creates default `TestControllerState`
     - Parameter itemNumber: current answering card
     - Parameter answers: Current user's answers
     */
    init(itemNumber: Int, answers: AnswersStorage) {
        self.itemNumber = itemNumber
        self.answers = answers
    }
}

/// Protocol for table view event handling
protocol ITestViewControllerTableViewCellReactor: class {
    /// Notifies when should add new answer
    func onAddLineForAnswer()
    
    /// Notifies when answer's cell was deleted
    func onDeleteLineForAnswer(sender: UITableViewCell)
}

/// Protocol for `DbUserCard` dto
protocol IUserCardForTestViewController {
    /// Card's translated word
    var translatedWord: String? { get }
    /// Amount of translations in this card
    var translationsCount: Int { get }
}

class UserCardForTestViewController: IUserCardForTestViewController {
    var translatedWord: String?
    var translationsCount: Int
    
    /**
     Creates new `UserCardForTestViewController`
     - Parameter translatedWord: Card's translated word
     - Parameter translationsCount: Amount of translations in this card
     */
    init(translatedWord: String?, translationsCount: Int) {
        self.translatedWord = translatedWord
        self.translationsCount = translationsCount
    }
    
    /**
     Creates `UserCardForTestViewController` from given card
     */
    static func initFrom(card: DbUserCard) -> UserCardForTestViewController {
        return UserCardForTestViewController(translatedWord: card.translatedWord, translationsCount: card.getTranslations().count)
    }
}

/// Protocol for CoreData relative events handling
protocol ITestViewControllerCoreDataHandler {
    /// Creates tests
    func initializeCoreDataTest()
    
    /// Cancels tests
    func cancelTest(completionBlock: (() -> ())?)
    
    /// Saves test
    func saveCoreDataTest(answers: AnswersStorage,completionBlock: ((DbUserTest) -> ())?)
}

/// Protocol for delivering data to `ITestViewControllerDataSource`
protocol ITestViewControllerDataProvider: ITestViewControllerCoreDataHandler {
    /// Gets `UserCardForTestViewController` at given pos
    func getItem(cardPos: Int) -> UserCardForTestViewController
    /// Total amount of card
    var count: Int { get }
    /// Dictionary name
    var dictName: String? { get }
}


class TestViewControllerDataProvider: ITestViewControllerDataProvider {
    func getItem(cardPos: Int) -> UserCardForTestViewController {
        return translatedWords[cardPos]
    }
    
    var count: Int
    
    var dictName: String?
        
    private var sourceDict: DbUserDictionary
    
    private var cards: [DbUserCard]
    
    private var translatedWords: [UserCardForTestViewController]
    
    private var dbUserTest: DbUserTest!
    
    private var storageManager: IStorageCoordinator
    
    /// Synchronization trick not to save test bwfore it was created
    private var dispatchGroup = DispatchGroup()
    
    func initializeCoreDataTest() {
        dbUserTest = DbUserTest.createUserTestFor(context: self.storageManager.stack.mainContext, dict: self.sourceDict)
        dispatchGroup.enter()
        self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext) {
            self.dispatchGroup.leave()
        }
    }
    
    func cancelTest(completionBlock: (() -> ())?) {
        self.storageManager.stack.mainContext.delete(dbUserTest)
        self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext, completion: completionBlock)
    }
    
    func saveCoreDataTest(answers: AnswersStorage, completionBlock: ((DbUserTest) -> ())?) {
        DispatchQueue.global(qos: .background).async {
            self.dispatchGroup.wait()
            
            self.storageManager.stack.mainContext.performAndWait {
                for dbTestCard in self.dbUserTest.testDict!.getCards() {
                    let ind = self.cards.firstIndex(of: dbTestCard.sourceCard!)!
                    
                    let currCardAnswers = answers[ind]
                    
                    let transArr = dbTestCard.getTranslations()
                    
                    for dbTranlsation in transArr {
                        if (currCardAnswers.filter({ (answer) -> Bool in
                            return dbTranlsation.translation!.lowercased().trimmingCharacters(in: .whitespaces) == answer.answer.lowercased().trimmingCharacters(in: .whitespaces)
                            }).count > 0) {
                            dbTranlsation.isRightAnswered = true
                            
                            currCardAnswers.forEach { (answer) in
                                if let dbanswer = DbUserTestAnswer.insertUserTestAnswer(into: self.storageManager.stack.mainContext) {
                                    dbanswer.userAnswer = answer.answer
                                    dbTestCard.addToUserAnswers(dbanswer)
                                }
                            }
                        }
                    }
                }
                self.dbUserTest.endTest()
            }
            
            self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext) {
                completionBlock?(self.dbUserTest)
            }
        }
    }
    
    /**
     Creates new `TestViewControllerDataProvider`
     - Parameter sourceDictionary: to create test for this dictionary
     - Parameter storageManager: service for manipulating with CoreData
     */
    init(sourceDictionary: DbUserDictionary, storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
        self.sourceDict = sourceDictionary
        self.cards = sourceDictionary.getCards().shuffled()
        self.count = self.cards.count
        self.translatedWords = self.cards.map({ (card) -> UserCardForTestViewController in
            return UserCardForTestViewController.initFrom(card: card)
        })
        self.dictName = sourceDictionary.name
        initializeCoreDataTest()
    }
}

/// Protocol for handling user's answers
protocol ITestViewControllerDataSource: UITableViewDataSource, UITableViewDelegate, ITestViewControllerTableViewCellReactor, ITestControllerTranslationCellDelegate {
    /// Current user's progress state
    var state: ITestControllerState { get }
    /// Service for delivering additional info for `ITestViewControllerDataSource`
    var dataProvider: ITestViewControllerDataProvider { get }
    /// Event handler
    var reactor: ITestViewControllerDataSourceReactor? { get set }
    /// For handling last focused text field
    var onFocusedLabelDelegate: IScrollableToPoint? { get set }
}

/// `ITestViewControllerDataSource` event handler
protocol ITestViewControllerDataSourceReactor: class {
    /// Add rows in table view
    func addItems(indexPaths: [IndexPath])
    /// Delete row from table view
    func deleteItems(indexPaths: [IndexPath])
    
    var tableView: UITableView { get }
}

/// Table View cell's event handler
protocol ITextFieldTestControllerEditingDelegate: class {
    /// Notifies when user begin editing in given cell
    func beginEditingInCell(cell: UITableViewCell)
    
    /// Notifies when user end editing in given cell
    func endEditingInCell(cell: UITableViewCell)
}

class TestViewControllerDataSource: NSObject, ITestViewControllerDataSource, ITextFieldTestControllerEditingDelegate {
    var state: ITestControllerState
    var dataProvider: ITestViewControllerDataProvider
    weak var reactor: ITestViewControllerDataSourceReactor?
    weak var onFocusedLabelDelegate: IScrollableToPoint?
    
    func endEditingInCell(cell: UITableViewCell) {
        Logger.log("end editing")
        //onFocusedLabelDelegate?.scrollToTop()
    }
        
    func beginEditingInCell(cell: UITableViewCell) {
        let rect = reactor!.tableView.rectForRow(at: reactor!.tableView.indexPath(for: cell)!)
        Logger.log("rect: \(rect)")
        let point = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height)
        
        onFocusedLabelDelegate?.scrollToPoint(point: point, sender: reactor!.tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.answers[self.state.itemNumber].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestControllerTranslationTableViewCell.cellId, for: indexPath) as? TestControllerTranslationTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.editingDelegate = self
        cell.setup(config: TestControllerTranslationCellConfiguration(translation: state.answers[state.itemNumber][indexPath.row].answer))
        return cell
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let removeAction = UIContextualAction(style: .normal, title: "Remove") { (action, view, _) in
//            if let cell = tableView.cellForRow(at: indexPath) {
//                self.onDeleteLineForAnswer(sender: cell)
//            }
//        }
//
//        removeAction.image = #imageLiteral(resourceName: "criss-cross")
//
//        removeAction.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0)
//        let config = UISwipeActionsConfiguration(actions: [removeAction])
//        config.performsFirstActionWithFullSwipe = false
//        return config
//    }
    
    func onAddLineForAnswer() {
        self.state.answers.append(pos: state.itemNumber, answer: TestControllerAnswer(answer: ""))
        reactor?.addItems(indexPaths: [IndexPath(row: self.state.answers[self.state.itemNumber].count - 1, section: 0)])
    }
    
    func onDeleteLineForAnswer(sender: UITableViewCell) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        self.state.answers.remove(pos1: self.state.itemNumber, pos2: indexPath.row)
        reactor?.deleteItems(indexPaths: [indexPath])
    }
    
    func textDidChange(sender: UITableViewCell, text: String?) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        self.state.answers.setAnswer(pos1: self.state.itemNumber, pos2: indexPath.row, answer: text ?? "")
    }
    
    func onReturn(sender: UITableViewCell) {
        let indexPath = reactor!.tableView.indexPath(for: sender)!
        if let cell = reactor!.tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section)) as? TestControllerTranslationTableViewCell {
            cell.translationTextField.becomeFirstResponder()
        } else {
            //onFocusedLabelDelegate?.scrollToTop()
        }
    }
    
    /**
     Creates new `TestViewControllerDataSource`
     - Parameter state: current user's progress state
     - Parameter dataProvider: service for delvering neccesarry data for `TestViewControllerDataSource`
     */
    init(state: ITestControllerState, dataProvider: ITestViewControllerDataProvider) {
        self.state = state
        self.dataProvider = dataProvider
        
        super.init()
        addAnswers()
    }
    
    /**
     Adds needed amount of answers so user shouldnt click on plus button multiple times
     */
    func addAnswers() {
        for _ in 0..<self.dataProvider.getItem(cardPos: self.state.itemNumber).translationsCount {
            onAddLineForAnswer()
        }
    }
}

/// Service for handling all `TestController` inner logic
protocol ITestViewControllerModel {
    /// Service for handling user's answers and table view data
    var dataSource: ITestViewControllerDataSource { get }
    /// Ends test
    func endTest(completionBlock: ((DbUserTest) -> ())?)
    /// Cancels test
    func cancelTest(completionBlock: (() -> ())?)
}

class TestViewControllerModel: ITestViewControllerModel {
    var dataSource: ITestViewControllerDataSource
    
    func endTest(completionBlock: ((DbUserTest) -> ())?) {
        self.dataSource.dataProvider.saveCoreDataTest(answers: self.dataSource.state.answers, completionBlock: completionBlock)
    }
    
    func cancelTest(completionBlock: (() -> ())?) {
        self.dataSource.dataProvider.cancelTest(completionBlock: completionBlock)
    }
    
    /**
     Creates new `TestViewControllerModel`
     - Parameter dataSource: Service for handling user's answers and table view data
     */
    init(dataSource: ITestViewControllerDataSource) {
        self.dataSource = dataSource
    }
}
