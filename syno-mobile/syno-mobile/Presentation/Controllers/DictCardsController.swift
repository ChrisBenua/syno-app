import Foundation
import UIKit

/// Controller for editing dictionary cards
class DictCardsController: UIViewController {
    /// FetchResultsController delegate for collection view
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    /// Service responsible for formatting data for Collection view
    var dataSource: ICardsControllerDataSource
    
    /// NotificationView for cancelling deletion
    var notifView: BottomNotificationView?
    
    /// Collection view for displaying dictionary cards
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.alwaysBounceVertical = true
        colView.backgroundColor = .white
        colView.delegate = self.dataSource
        
        colView.contentInset = UIEdgeInsets(top: 30, left: 15, bottom: 0, right: 15)
        
        colView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.cellId)
        colView.register(EmptyCardsCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmptyCardsCollectionViewHeader.headerId)
        return colView
    }()
    
    /// Assembly for creating controllers
    let assembly: IPresentationAssembly
    
    /**
     Creates new `DictCardsController`
     - Parameter dataSource: service responsible for data formatting in collection view
     - Parameter presAssembly: Assembly for creating controllers
     */
    init(dataSource: ICardsControllerDataSource, presAssembly: IPresentationAssembly) {
        self.dataSource = dataSource
        self.assembly = presAssembly
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DefaultCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.dataSource.delegate = self
        self.collectionView.dataSource = self.dataSource
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.notifView?.removeFromSuperview()
        self.dataSource.commitChanges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Карточки"
        
        self.dataSource.performFetch()
        self.view.addSubview(self.collectionView)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCard))
        self.navigationItem.rightBarButtonItem?.tintColor = .headerMainColor
        
        if #available(iOS 13, *) {} else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnCollectionView(gesture:)))
            longPress.delaysTouchesBegan = true
            self.collectionView.addGestureRecognizer(longPress)
        }
        
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc func handleLongPressOnCollectionView(gesture: UILongPressGestureRecognizer) {
        let p = gesture.location(in: self.collectionView)

        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            let alert = UIAlertController(title: "Действия", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (_) in
                self.dataSource.handleDeletion(indexPath: indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("couldn't find index path")
        }
    }
    
    /// Plus bar button click listener
    @objc func addCard() {
        self.dataSource.createEmptyUserCard { (tempCard) in
            DispatchQueue.main.async {
                let controller = self.assembly.newCardController(tempSourceCard: tempCard)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DictCardsController: ICardsDataSourceReactor {
    func onSelectedItem(item: DbUserCard) {
        let controller = self.assembly.translationsViewController(sourceCard: item)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onItemDeleted() {
        let notifView = BottomNotificationView()
        notifView.cancelButtonLabel.text = "Отмена"
        notifView.messageLabel.text = "Карточка будет удалена"
        notifView.timerLabel.text = "5"
        notifView.delegate = self
        self.view.addSubview(notifView)
        self.view.bringSubviewToFront(notifView)
        notifView.anchor(top: nil, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.notifView = notifView
    }
}

extension DictCardsController: IBottomNotificationViewDelegate {
    func onCancelButtonPressed() {
        Logger.log("Canceled deletion")
        self.dataSource.undoLastDeletion()
    }
    
    func onTimerDone() {
        Logger.log("Timer in undo deletion done")
        self.dataSource.commitChanges()
    }
}
