import Foundation
import UIKit
import CoreData

enum TestAndLearnModes {
    case learnMode
    case testMode
}

protocol ITestAndLearnStateReactor: class {
    func onStateChanged(newState: TestAndLearnModes)
}

protocol ITestAndLearnReactor: class {
    func showLearnController(controller: UIViewController)
    
    func onChangeControllerTitle(newMode: TestAndLearnModes)
}

protocol ITestAndLearnDictionaryControllerState {
    var testAndLearnMode: TestAndLearnModes { get set }
}

class TestAndLearnDictionaryControllerState: ITestAndLearnDictionaryControllerState {
    var testAndLearnMode: TestAndLearnModes
    
    init() {
        testAndLearnMode = .learnMode
    }
}


protocol IRecentTestsDataProvider {
    func setLimit(limit: Int)
    
    func getLimit() -> Int
    
    func fetch() -> [ExtendedRecentTestTableViewCellConfiguration]
    
    func refresh()
    
    func getTestAt(pos: Int) -> DbUserTest
}

class ExtendedRecentTestTableViewCellConfiguration: IRecentTestTableViewCellConfiguration {
    var dictName: String?
    
    var grade: String?
    
    var objectId: NSManagedObjectID
    
    init(dictName: String?, grade: String?, objectId: NSManagedObjectID) {
        self.dictName = dictName
        self.grade = grade
        self.objectId = objectId
    }
}

class RecentTestsDataProvider: IRecentTestsDataProvider {
    private var storageManager: IStorageCoordinator
    
    private var fetchResults: [ExtendedRecentTestTableViewCellConfiguration]?
    
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
    
    func refresh() {
        do {
            let result: [DbUserTest] = try storageManager.stack.mainContext.fetch(DbUserTest.requestLatestTests(limit: self.limit))
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
    
    
    init(storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
    }
}


protocol IRecentTestsDataSource: UITableViewDataSource, UITableViewDelegate, IRecentTestsTitleViewDelegate {
    var viewModel: IRecentTestsDataProvider { get }
    func refresh()
    
    var delegate: IRecentTestsDataSourceReactor? { get set }
    
    func isExpanded() -> Bool
}

protocol IRecentTestsDataSourceReactor: class {
    func didExpandOrCollapseTableView()
    
    func openTestResultsController(with test: DbUserTest)
}

class RecentTestsDataSource: NSObject, IRecentTestsDataSource {
    weak var delegate: IRecentTestsDataSourceReactor?
    
    private var tableView: UITableView!
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
        
        UIView.animate(withDuration: 0.3 * TimeInterval(indexPath.row), animations: {
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
    
    init(viewModel: IRecentTestsDataProvider) {
        self.viewModel = viewModel
    }
}

protocol ITestAndLearnDictionaryDataSource: ICommonDictionaryControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ITestAndLearnHeaderDelegate {
    var state: ITestAndLearnDictionaryControllerState { get }
    var delegate: ITestAndLearnReactor? { get set }
    var recentTestsDataSource: IRecentTestsDataSource { get }
}

class TestAndLearnDictionaryDataSource: NSObject, ITestAndLearnDictionaryDataSource, IRecentTestsDataSourceReactor {
    func openTestResultsController(with test: DbUserTest) {
        let resultsController = self.presAssembly.testResultsController(sourceTest: test)
        self.delegate?.showLearnController(controller: resultsController)
    }
    
    func didExpandOrCollapseTableView() {
        self.collectionView.collectionViewLayout.invalidateLayout()
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
        self.collectionView.collectionViewLayout.invalidateLayout()
        delegate?.onChangeControllerTitle(newMode: state.testAndLearnMode)
        Logger.log("Mode in TestAndLearnController changed")
    }
    
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary>
    
    var viewModel: IDictionaryControllerDataProvider
    
    private var presAssembly: IPresentationAssembly
    
    var header: TestAndLearnControllerHeader?
    
    init(viewModel: IDictionaryControllerDataProvider, presAssembly: IPresentationAssembly, recentTestsDataSource: IRecentTestsDataSource) {
        self.viewModel = viewModel
        self.presAssembly = presAssembly
        self.recentTestsDataSource = recentTestsDataSource
        self.state = TestAndLearnDictionaryControllerState()
        fetchedResultsController = self.viewModel.generateDictControllerFRC()
        super.init()
        self.recentTestsDataSource.delegate = self
    }
        
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            Logger.log("Cant perform fetch")
            Logger.log(err.localizedDescription)
        }
    }
    
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
        if (self.state.testAndLearnMode == .learnMode) {
            let controller = self.presAssembly.learnController(sourceDict: self.fetchedResultsController.object(at: indexPath))
            self.delegate?.showLearnController(controller: controller)
        } else {
            let contoller = self.presAssembly.testController(sourceDict: self.fetchedResultsController.object(at: indexPath))
            self.delegate?.showLearnController(controller: contoller)
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
