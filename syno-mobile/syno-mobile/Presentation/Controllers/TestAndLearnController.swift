import Foundation
import UIKit

extension UISegmentedControl {
    /// Sets tint color for selected index
    func updateColors(selectedColor: UIColor) {
        for (index, subview) in self.subviews.enumerated() {
            if index == self.selectedSegmentIndex {
                subview.tintColor = selectedColor
            }
            else {
                subview.tintColor = self.tintColor
            }
        }
    }
}

class TestAndLearnViewController: UIViewController {
    /// FetchResultsController delegate
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    /// Service responsible for delivering data to collection view
    var dataSource: ITestAndLearnDictionaryDataSource
    
    /// Collection view for displaying dictionaries data
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
        
        colView.register(TestAndLearnCollectionViewCell.self, forCellWithReuseIdentifier: TestAndLearnCollectionViewCell.cellId)
        colView.register(TestAndLearnControllerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TestAndLearnControllerHeader.headerId)
        
        return colView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.collectionView.reloadData()
        self.dataSource.recentTestsDataSource.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Обучение"
        
        self.dataSource.performFetch()
        self.view.addSubview(self.collectionView)
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
    }
    
    /**
     Creates new `TestAndLearnViewController`
     - Parameter datasource: Service responsible for delivering data to collection view
     */
    init(datasource: ITestAndLearnDictionaryDataSource) {
        self.dataSource = datasource
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DefaultCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.dataSource.delegate = self
        self.collectionView.dataSource = self.dataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TestAndLearnViewController: ITestAndLearnReactor {
    func showActionSheetController(controller: UIAlertController) {
        self.present(controller, animated: true)
    }
  
    func onShowError(title: String, message: String?) {
        self.present(UIAlertController.okAlertController(title: title, message: message), animated: true)
    }
  
    func onChangeControllerTitle(newMode: TestAndLearnModes) {
        if (newMode == .learnMode) {
            self.navigationItem.title = "Обучение"
        } else {
            self.navigationItem.title = "Тестирование"
        }
    }
    
    func showLearnController(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
