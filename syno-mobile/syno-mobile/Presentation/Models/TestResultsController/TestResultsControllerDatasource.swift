import Foundation
import UIKit

/// Translations object to be presented on `TestResultsController`
protocol ITestResultsControllerTranslationDto {
    var translation: String? { get }
        
    /// True if user has written this `translation` in his test
    var isRightAnswered: Bool { get }
}

class TestResultsControllerTranslationDto: ITestResultsControllerTranslationDto {
    var translation: String?
    
    var isRightAnswered: Bool
    
    /**
     Creates new `TestResultsControllerTranslationDto`
     - Parameter translation: translation
     - Parameter isRightAnswered: Has user written this `translation` in his test
     */
    init(translation: String?, isRightAnswered: Bool) {
        self.translation = translation
        self.isRightAnswered = isRightAnswered
    }
}

/// Card wrapper to be presented on `TestResultsController`
protocol ITestResultsControllerCardResultDto {
    /// Cards translation
    var translations: [ITestResultsControllerTranslationDto] { get }
    /// Card's translated word
    var translatedWord: String? { get }
}

class TestResultsControllerCardResultsDto: ITestResultsControllerCardResultDto {
    var translations: [ITestResultsControllerTranslationDto]
    var translatedWord: String?
    
    /**
     Creates new `TestResultsControllerCardResultsDto`
     - Parameter translations: Card's translation
     - Parameter translatedWord: Card's translated word
     */
    init(translations: [ITestResultsControllerTranslationDto], translatedWord: String?) {
        self.translations = translations
        self.translatedWord = translatedWord
    }
}

/// `DbUserTest` wrapper to be presented on `TestResultsViewController`
protocol ITestResultsControllerTestResult {
    /// `DbUserTest` `testDict`'s cards
    var cardResults: [ITestResultsControllerCardResultDto] { get }
    /// `DbUserTest`'s source dict name
    var dictName: String? { get }
    /// `DbUserTest` grade
    var percentageScore: Int { get }
}

class TestResultsControllerTestResult: ITestResultsControllerTestResult {
    var percentageScore: Int
    
    var dictName: String?
    
    var cardResults: [ITestResultsControllerCardResultDto]
    
    /**
     Creates new `TestResultsControllerTestResult`
     - Parameter cards:`DbUserTest` `testDict`'s cards
     - Parameter dictName:`DbUserTest`'s source dict name
     - Parameter score:`DbUserTest` grade
     */
    init(cards: [ITestResultsControllerCardResultDto], dictName: String?, score: Int) {
        self.cardResults = cards
        self.dictName = dictName
        self.percentageScore = score
    }
}

/// Service protocol for delivering `DbUserTest` info to `TestResultsControllerDataSource`
protocol ITestResultsControllerDataProvider {
    /**
     Gets card at given position
     - Parameter pos: Card's index
     */
    func getCardAt(pos: Int) -> ITestResultsControllerCardResultDto
    
    /**
     Gets translation at given position
     - Parameter cardPos: Card's index
     - Parameter transPos: Translation's index
     */
    func getTranslationAt(cardPos: Int, transPos: Int) -> ITestResultsControllerTranslationDto
    
    /// Gets total amount of cards in test
    func totalCards() -> Int
    
    /// Gets test dict name
    func getDictName() -> String?
    
    /// Gets test's grade
    func getPercentageScore() -> Int
    
    /**
     Gets number of translation that were answered at given card's position
     - Parameter pos:Card's index
     */
    func rightAnsweredAt(pos: Int) -> Int
}

class TestResultsControllerDataProvider: ITestResultsControllerDataProvider {
    func rightAnsweredAt(pos: Int) -> Int {
        return self.testResult.cardResults[pos].translations.map { (translationDto: ITestResultsControllerTranslationDto) -> Int in
            if translationDto.isRightAnswered {
                return 1
            }
            return 0
        }.reduce(0) { (res, new) -> Int in
            return res + new
        }
    }
    
    func getPercentageScore() -> Int {
        return self.testResult.percentageScore
    }
    
    func getDictName() -> String? {
        return self.testResult.dictName
    }
    
    func getCardAt(pos: Int) -> ITestResultsControllerCardResultDto {
        return self.testResult.cardResults[pos]
    }
    
    func getTranslationAt(cardPos: Int, transPos: Int) -> ITestResultsControllerTranslationDto {
        return self.testResult.cardResults[cardPos].translations[transPos]
    }
    
    func totalCards() -> Int {
        return self.testResult.cardResults.count
    }
    
    /// `DbUserTest` dto
    private var testResult: ITestResultsControllerTestResult
    
    /**
     Creates new `TestResultsControllerDataProvider`
     - Parameter test: `DbUserTest` which results want to show
     */
    init(test: DbUserTest) {
        let cardsResults: [ITestResultsControllerCardResultDto] = test.testDict!.getCards().map { (dbUserTestCard) -> ITestResultsControllerCardResultDto in
            return TestResultsControllerCardResultsDto(translations: dbUserTestCard.getTranslations().map({ (el) -> ITestResultsControllerTranslationDto in
                return TestResultsControllerTranslationDto(translation: el.translation, isRightAnswered: el.isRightAnswered)
            }), translatedWord: dbUserTestCard.translatedWord)
        }
        
        self.testResult = TestResultsControllerTestResult(cards: cardsResults, dictName: test.targetedDict?.name, score: Int(test.gradePercentage))
    }
}

/// Service responsible for filling table view with results and whole `TestResultsController`
protocol ITestResultsControllerDataSource: UITableViewDelegate, UITableViewDataSource, ITestResultsHeaderViewDelegate {
    /// Gets test's dictionary name
    func getDictName() -> String?
    
    /// Gets test's grade
    func getPercentageScore() -> Int
}

/// Protocol for controlling `ITestResultsControllerDataSource` state
protocol ITestResultsControllerState {
    var isSectionExpanded: [Bool] { get set }
    
    /// Last collapsed or expanded section
    var lastToggle: Int? { get set }
}


class TestResultsControllerState: ITestResultsControllerState {
    var isSectionExpanded: [Bool]
    
    var lastToggle: Int?
    /**
     Creates `TestResultsControllerState` with desired amount of sections
     */
    init(withDefaultSize: Int) {
        self.isSectionExpanded = Array.init(repeating: false, count: withDefaultSize)
    }
    
    /**
     Creates `TestResultsControllerState` with given state array
     - Parameter isSectionExpanded: sections' state array
     */
    init(isSectionExpanded: [Bool]) {
        self.isSectionExpanded = isSectionExpanded
    }
}

class TestResultsControllerDataSource: NSObject, ITestResultsControllerDataSource {
    /// Service for delivering data for filling table view
    private var dataProvider: ITestResultsControllerDataProvider
    /// Instance for saving `TestResultsControllerDataSource` state
    private var state: ITestResultsControllerState
    
    var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView
        return dataProvider.totalCards()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let mycell = cell as! TestResultsTableViewCell
        if (state.lastToggle == indexPath.section) {
            mycell.baseShadowView.alpha = 0
            
            UIView.animate(withDuration: 0.3 * Double(indexPath.row + 1), animations: {
                mycell.baseShadowView.alpha = 1
            })
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TestResultsTableViewHeaderView()
        view.delegate = self
        let card = self.dataProvider.getCardAt(pos: section)
        view.configure(config: TestResultsHeaderConfiguration(translatedWord: card.translatedWord, rightAnswered: self.dataProvider.rightAnsweredAt(pos: section), allTranslations: card.translations.count, section: section, isExpanded: self.state.isSectionExpanded[section], shouldAnimate: self.state.lastToggle == section))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (state.isSectionExpanded[section]) {
            return dataProvider.getCardAt(pos: section).translations.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestResultsTableViewCell.cellId, for: indexPath) as? TestResultsTableViewCell else {
            fatalError()
        }
        var color = #colorLiteral(red: 0.9568627451, green: 0.7960784314, blue: 0.8039215686, alpha: 1)
        let trans = self.dataProvider.getTranslationAt(cardPos: section, transPos: row)
        if trans.isRightAnswered {
            color = #colorLiteral(red: 0.737254902, green: 0.9921568627, blue: 0.7960784314, alpha: 1)
        }
        
        cell.configure(config: TestResultsTableViewCellConfiguration(translation: trans.translation, backgroundColor: color))
        
        return cell
    }
    
    func didChangeExpandStateAt(section: Int) {
        self.state.lastToggle = section
        self.state.isSectionExpanded[section].toggle()
        self.tableView.reloadData()
    }
    
    func getDictName() -> String? {
        return self.dataProvider.getDictName()
    }
    
    func getPercentageScore() -> Int {
        return self.dataProvider.getPercentageScore()
    }
    
    /**
     Creates new `TestResultsControllerDataSource`
     - Parameter dataProvider: service responsible for delivering data to this instance
     - Parameter state: `TestResultsControllerDataSource` initial state
     */
    init(dataProvider: ITestResultsControllerDataProvider, state: ITestResultsControllerState) {
        self.dataProvider = dataProvider
        self.state = state
    }
}
