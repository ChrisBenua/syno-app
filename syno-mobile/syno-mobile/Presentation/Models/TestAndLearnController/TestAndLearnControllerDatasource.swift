import Foundation
import UIKit
import CoreData

/// Enum for defining mode in `TestAndLearnController`
enum TestAndLearnModes {
    case learnMode
    case testMode
}

/// Defines event handler for switching mode
protocol ITestAndLearnStateReactor: class {
    /// Notifies when mode was switched to `newState`
    func onStateChanged(newState: TestAndLearnModes)
}

/// `ITestAndLearnDictionaryDataSource` event handler
protocol ITestAndLearnReactor: class {
    /// Shows new view controller
    func showLearnController(controller: UIViewController)
  
    func showActionSheetController(controller: UIAlertController)
    
    /// Notifies when should change title
    func onChangeControllerTitle(newMode: TestAndLearnModes)
    
    func onShowError(title: String, message: String?)
}

/// Protocol for storing `TestAndLearnController` state
protocol ITestAndLearnDictionaryControllerState {
    var testAndLearnMode: TestAndLearnModes { get set }
}

class TestAndLearnDictionaryControllerState: ITestAndLearnDictionaryControllerState {
    var testAndLearnMode: TestAndLearnModes
    
    init() {
        testAndLearnMode = .learnMode
    }
}

/// Protocol for delivering info about recent tests
protocol IRecentTestsDataProvider {
    /// Sets fetch limit
    func setLimit(limit: Int)
    
    /// Gets fetch limit
    func getLimit() -> Int
    
    /// Fetches data
    func fetch() -> [ExtendedRecentTestTableViewCellConfiguration]
    
    /// Refreshes data
    func refresh()
    
    /// Gets test for given position
    func getTestAt(pos: Int) -> DbUserTest
}

class ExtendedRecentTestTableViewCellConfiguration: IRecentTestTableViewCellConfiguration {
    var dictName: String?
    
    var grade: String?
    
    var objectId: NSManagedObjectID
    
    /**
     Creates new `ExtendedRecentTestTableViewCellConfiguration`
     - Parameter dictName: Dictionary name
     - Parameter grade: Test grade
     - Parameter objectId: test's `NSManagedObjectID`
     */
    init(dictName: String?, grade: String?, objectId: NSManagedObjectID) {
        self.dictName = dictName
        self.grade = grade
        self.objectId = objectId
    }
}

class RecentTestsDataProvider: IRecentTestsDataProvider {
    /// Service for interacting with CoreData
    private var storageManager: IStorageCoordinator
    
    /// Results for last performed fetch
    private var fetchResults: [ExtendedRecentTestTableViewCellConfiguration]?
    
    /// Fetch limit
    private var limit = 5
    
    func setLimit(limit: Int) {
        self.limit = limit
    }
    
    func getLimit() -> Int {
        return self.limit
    }
    
    func fetch() -> [ExtendedRecentTestTableViewCellConfiguration] {
        if let res = fetchResults {
            return res
        }
    
        refresh()
        return self.fetchResults ?? []
    }
    
    /// Fetches data from `CoreData`
    func refresh() {
        do {
            let result: [DbUserTest] = try storageManager.stack.mainContext.fetch(DbUserTest.requestLatestTests(limit: self.limit, owner: self.storageManager.getCurrentUserEmail() ?? "Guest"))
            self.fetchResults = result.map({ (el) -> ExtendedRecentTestTableViewCellConfiguration in
                return ExtendedRecentTestTableViewCellConfiguration(dictName: el.targetedDict?.name, grade: "\(Int(el.gradePercentage))%", objectId: el.objectID)
            })
        } catch let err {
            Logger.log("Fetch Error in \(#function): \(err.localizedDescription)")
        }
    }
    
    func getTestAt(pos: Int) -> DbUserTest {
        let test = self.storageManager.stack.mainContext.object(with: self.fetchResults![pos].objectId) as! DbUserTest
        return test
    }
    
    /**
     Creates new `RecentTestsDataProvider`
     - Parameter storageManager: service for interacting with coredata
     */
    init(storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
    }
}

/// Protocol for rendering list of recent tests
protocol IRecentTestsDataSource: UITableViewDataSource, UITableViewDelegate, IRecentTestsTitleViewDelegate {
    /// Service for data delivery
    var viewModel: IRecentTestsDataProvider { get }
    /// refreshes data in `viewModel`
    func refresh()
    
    /// event handler
    var delegate: IRecentTestsDataSourceReactor? { get set }
    
    /// If list expanded
    func isExpanded() -> Bool
}

/// `IRecentTestsDataSource` event handler
protocol IRecentTestsDataSourceReactor: class {
    /// Notifies when list was expanded or collapsed
    func didExpandOrCollapseTableView()
    
    /// Opens TestResultsControlelr with given test
    func openTestResultsController(with test: DbUserTest)
}

class RecentTestsDataSource: NSObject, IRecentTestsDataSource {
    weak var delegate: IRecentTestsDataSourceReactor?
    
    private var tableView: UITableView!
    /// Is recent tests list expanded
    private var isExpanded_: Bool = false
    
    private var recentTestTitleView: RecentTestsTitleView?
    
    func isExpanded() -> Bool {
        return isExpanded_
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        
        if isExpanded_ {
            Logger.log("Recent Tests table view is expanded")
            return self.viewModel.fetch().count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let test = self.viewModel.getTestAt(pos: indexPath.row)
        self.delegate?.openTestResultsController(with: test)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = recentTestTitleView {
            return view
        }
        
        let view = RecentTestsTitleView(isExpanded: self.isExpanded())
        view.delegate = self
        view.isExpanded = self.isExpanded_
        self.recentTestTitleView = view
        
        return self.recentTestTitleView!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myCell = cell as! RecentTestTableViewCell
        myCell.baseShadowView.alpha = 0
        
        UIView.animate(withDuration: 0.3 * TimeInterval(indexPath.row) + 0.2, animations: {
            myCell.baseShadowView.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTestTableViewCell.cellId, for: indexPath) as? RecentTestTableViewCell
            else {
                fatalError()
        }
        
        cell.configure(config: self.viewModel.fetch()[indexPath.row])
        return cell
    }
    
    func didChangeState(isExpanded: Bool) {
        if (self.isExpanded_ != isExpanded) {
            self.delegate?.didExpandOrCollapseTableView()
            self.isExpanded_ = isExpanded
            self.tableView.reloadData()
        }
    }
    
    var viewModel: IRecentTestsDataProvider
    
    func refresh() {
        self.viewModel.refresh()
        if self.tableView != nil {
            self.tableView.reloadData()
        }
    }
    
    /**
     Creates new `RecentTestsDataSource`
     - Parameter viewModel: Service for data delivery
     */
    init(viewModel: IRecentTestsDataProvider) {
        self.viewModel = viewModel
    }
}

/// Protocol for Collection view data rendering
protocol ITestAndLearnDictionaryDataSource: ICommonDictionaryControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ITestAndLearnHeaderDelegate {
    /// Current state
    var state: ITestAndLearnDictionaryControllerState { get }
    /// Event handler
    var delegate: ITestAndLearnReactor? { get set }
    /// Service for rendering recent tests list
    var recentTestsDataSource: IRecentTestsDataSource { get }
}

class TestAndLearnDictionaryDataSource: NSObject, ITestAndLearnDictionaryDataSource, IRecentTestsDataSourceReactor {
    func openTestResultsController(with test: DbUserTest) {
        let resultsController = self.presAssembly.testResultsController(sourceTest: test)
        self.delegate?.showLearnController(controller: resultsController)
    }
    
    func didExpandOrCollapseTableView() {
        //UIView.animate(withDuration: 0.5) {
            self.collectionView.collectionViewLayout.invalidateLayout()
        //}
    }
    
    weak var delegate: ITestAndLearnReactor?
    
    var state: ITestAndLearnDictionaryControllerState
    
    var recentTestsDataSource: IRecentTestsDataSource
    
    var collectionView: UICollectionView!
    
    func onSegmentChanged() {
        if state.testAndLearnMode == .learnMode {
            state.testAndLearnMode = .testMode
        } else {
            state.testAndLearnMode = .learnMode
        }

        let view = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as! TestAndLearnControllerHeader
        updateHeader(header: view)
        //UIView.animate(withDuration: 0.5) {
            self.collectionView.collectionViewLayout.invalidateLayout()
        //}
        delegate?.onChangeControllerTitle(newMode: state.testAndLearnMode)
        Logger.log("Mode in TestAndLearnController changed")
    }
    
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary>
    
    var viewModel: IDictionaryControllerDataProvider
    
    /// Assembly for creating view controllers
    private var presAssembly: IPresentationAssembly
    
    var header: TestAndLearnControllerHeader?
    
    /**
     Creates new `TestAndLearnDictionaryDataSource`
     - Parameter viewModel: data delivery service
     - Parameter presAssembly: assembly for creating view controllers
     - Parameter recentTestsDataSource: data delivery service
     */
    init(viewModel: IDictionaryControllerDataProvider, presAssembly: IPresentationAssembly, recentTestsDataSource: IRecentTestsDataSource) {
        self.viewModel = viewModel
        self.presAssembly = presAssembly
        self.recentTestsDataSource = recentTestsDataSource
        self.state = TestAndLearnDictionaryControllerState()
        fetchedResultsController = self.viewModel.generateDictControllerFRC()
        super.init()
        self.recentTestsDataSource.delegate = self
    }
        
    /// Performs fetch in FetchedResultsController
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            Logger.log("Cant perform fetch")
            Logger.log(err.localizedDescription)
        }
    }
    
    /// Updates collection view header if necessary
    private func updateHeader(header: TestAndLearnControllerHeader) {
        switch self.state.testAndLearnMode {
        case .learnMode:
            header.segmentControl.selectedSegmentIndex = 0
            header.tableView.isHidden = true
        case .testMode:
            header.tableView.isHidden = false
            header.segmentControl.selectedSegmentIndex = 1
            header.tableView.dataSource = self.recentTestsDataSource
            header.tableView.delegate = self.recentTestsDataSource
            header.tableView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TestAndLearnControllerHeader.headerId, for: indexPath) as! TestAndLearnControllerHeader
        header.delegate = self
        
        updateHeader(header: header)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView = collectionView
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in FRC")
        }
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestAndLearnCollectionViewCell.cellId, for: indexPath) as? TestAndLearnCollectionViewCell else {
            fatalError()
        }
        
        cell.setup(config: self.fetchedResultsController.object(at: indexPath).toTestAndLearnCellConfiguration())
        return cell
    }
}

extension TestAndLearnDictionaryDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = self.fetchedResultsController.object(at: indexPath)
        
        if dict.getCards().count == 0 {
            let errMode = self.state.testAndLearnMode == .learnMode ? "обучение" : "тест"
            self.delegate?.onShowError(title: "Ошибка", message: "Невозможно начать \(errMode). Словарь пуст")
        } else {
            if (self.state.testAndLearnMode == .learnMode) {
                let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
              actionController.addAction(UIAlertAction(title: "Обычный(" + (self.fetchedResultsController.object(at: indexPath).language ?? "") + ")", style: .default, handler: { (_) in
                  let controller = self.presAssembly.learnController(sourceDict: dict)
                  self.delegate?.showLearnController(controller: controller)
              }))
              let language = self.fetchedResultsController.object(at: indexPath).language ?? ""
              var reversedLanguage = language.split(whereSeparator: { (ch) -> Bool in
                !ch.isLetter
              }).reversed().reduce("", { $0 + "-" + $1 })
              if reversedLanguage.count > 1 && reversedLanguage.first == "-" {
                  reversedLanguage = reversedLanguage.substring(from: reversedLanguage.index(after: reversedLanguage.startIndex))
              }
              actionController.addAction(UIAlertAction(title: "Наоборот(" + reversedLanguage + ")", style: .default, handler: { (_) in
                  
                  let controller = self.presAssembly.reversedLearnController(sourceDict: dict)
                  self.delegate?.showLearnController(controller: controller)
              }))
                actionController.addAction(UIAlertAction(title: "Режим прослушивания", style: .default, handler: { (_) in
                    self.delegate?.showLearnController(controller: self.presAssembly.voiceDictionaryNarrationController(dictionary: dict))
                }))
              actionController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (_) in
                  actionController.dismiss(animated: true)
              }))
              self.delegate?.showActionSheetController(controller: actionController)
            } else {
                let contoller = self.presAssembly.testController(sourceDict: dict)
                self.delegate?.showLearnController(controller: contoller)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2-20, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.state.testAndLearnMode == .learnMode {
            return CGSize(width: collectionView.frame.width, height: 70)
        } else {
            if (self.recentTestsDataSource.isExpanded()) {
                return CGSize(width: collectionView.frame.width, height: CGFloat(120 + 280 / 5 * self.recentTestsDataSource.viewModel.fetch().count))
            } else {
                return CGSize(width: collectionView.frame.width, height: 120)
            }
        }
    }
}
