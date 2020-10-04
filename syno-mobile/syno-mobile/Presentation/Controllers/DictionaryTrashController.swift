import Foundation
import UIKit


class DictsTrashViewController: UIViewController, ITrashDictionaryControllerReactor {
    
    func showCardsController(controller: UIViewController) {
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    /// FetchResultsController delegate
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    /// Service responsible for data formatting for collection view logic
    var dataSource: ITrashDictionaryControllerTableViewDataSource
    
    /**
     Creates new `DictsViewController`
     - Parameter datasource: Service responsible for data formatting for collection view logic
     - Parameter model: Service responsible for inner logic of `DictsViewController` controller
     */
    init(datasource: ITrashDictionaryControllerTableViewDataSource) {
        self.dataSource = datasource
        super.init(nibName: nil, bundle: nil)
        frcDelegate = TrashDictsControllerCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.collectionView.dataSource = self.dataSource
        self.dataSource.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Collection view for displaying user's dictionaries
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: 0, right: 15)
        
        colView.register(DictionaryCollectionViewCell.self, forCellWithReuseIdentifier: DictionaryCollectionViewCell.cellId)
        colView.register(EmptyDictTrashCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmptyDictTrashCollectionViewHeader.headerId)
        
        return colView
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.log(#function)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Корзина"

        self.dataSource.performFetch()
        self.view.addSubview(self.collectionView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action: #selector(onClearButtonClick))
        self.navigationItem.rightBarButtonItem?.tintColor = .headerMainColor
        
        if #available(iOS 13.0, *) {} else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnCollectionView(gesture:)))
            longPress.delaysTouchesBegan = true
            self.collectionView.addGestureRecognizer(longPress)
        }

        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc func onClearButtonClick() {
        self.dataSource.handleClear()
    }
    
    @objc func handleLongPressOnCollectionView(gesture: UILongPressGestureRecognizer) {

        let p = gesture.location(in: self.collectionView)

        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            let alert = UIAlertController(title: "Действия", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (_) in
                self.dataSource.handleDeletion(indexPath: indexPath)
            }
            
            let restoreAction = UIAlertAction(title: "Восстановить", style: .default) { (_) in
                self.dataSource.handleRestore(indexPath: indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(restoreAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("couldn't find index path")
        }
    }
}
