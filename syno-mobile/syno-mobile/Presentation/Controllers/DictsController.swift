import Foundation
import UIKit

/// Controller for presenting dicts in edit mode
class DictsViewController: UIViewController, IDictionaryControllerReactor {
    /// Process view for sharing process
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Sharing...")
        
        return view
    }()
    
    /// shows `processingSaveView`
    func showSharingProcessView() {
        processingSaveView.showSavingProcessView(sourceView: self)
    }
    
    /// Show success alert controller
    func showSharingResultView(text: String, title: String) {
        processingSaveView.dismissSavingProcessView()
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showCardsController(controller: UIViewController) {
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    /// Cancel deletion view
    var notifView: BottomNotificationView?
    
    /// FetchResultsController delegate
    var frcDelegate: IDefaultCollectionViewFetchResultControllerDelegate?
    
    /// Service responsible for data formatting for collection view logic
    var dataSource: IDictionaryControllerTableViewDataSource
    
    /// Service responsible for inner logic of `DictsViewController` controller
    var model: IDictControllerModel
    
    /**
     Creates new `DictsViewController`
     - Parameter datasource: Service responsible for data formatting for collection view logic
     - Parameter model: Service responsible for inner logic of `DictsViewController` controller
     */
    init(datasource: IDictionaryControllerTableViewDataSource, model: IDictControllerModel) {
        self.dataSource = datasource
        self.model = model
        super.init(nibName: nil, bundle: nil)
        frcDelegate = DictsControllerCollectionViewFRCDelegate(collectionView: self.collectionView)
        self.dataSource.fetchedResultsController.delegate = frcDelegate
        self.collectionView.dataSource = self.dataSource
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
        
        return colView
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.notifView?.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Словари"

        self.dataSource.performFetch()
        self.dataSource.delegate = self
        
        self.view.addSubview(self.collectionView)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddNewDictionary))
        self.navigationItem.rightBarButtonItem?.tintColor = .headerMainColor
        
        if #available(iOS 13.0, *) {} else {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnCollectionView(gesture:)))
            longPress.delaysTouchesBegan = true
            self.collectionView.addGestureRecognizer(longPress)
        }

        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        askForFetch()
    }
    
    @objc func handleLongPressOnCollectionView(gesture: UILongPressGestureRecognizer) {
//        if gesture.state != .ended {
//            return
//        }
        let p = gesture.location(in: self.collectionView)

        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            let alert = UIAlertController(title: "Действия", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (_) in
                self.dataSource.handleDeletion(indexPath: indexPath)
            }
            
            let shareAction = UIAlertAction(title: "Поделиться", style: .default) { (_) in
                self.dataSource.handleShare(indexPath: indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(shareAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("couldn't find index path")
        }
    }
    
    /// On TabBar plus button click handler
    @objc func onAddNewDictionary() {
        let actionController = UIAlertController(title: "Новый словарь", message: nil, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "Свой", style: .default, handler: { (_) in
            self.navigationController?.pushViewController(self.dataSource.getNewDictController(), animated: true)
        }))
        actionController.addAction(UIAlertAction(title: "Добавить по коду", style: .default, handler: { (_) in
            self.navigationController?.pushViewController(self.dataSource.addShareController(), animated: true)
        }))
        actionController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (_) in
            actionController.dismiss(animated: true, completion: nil)
        }))
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    /// Ask if user wants to download dictionaries from server
    func askForFetch() {
        if self.dataSource.fetchedResultsController.fetchedObjects?.count == 0 && self.dataSource.isAuthorized() {
            let alertController = UIAlertController(title: "Загрузка", message: "Загрузить копию?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                self.model.initialFetch(completion: { (_) in
                })
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Called when dictionary was deleted and presents `notifView` to cancel action
    func onItemDeleted() {
        let notifView = BottomNotificationView()
        notifView.cancelButtonLabel.text = "Отмена"
        notifView.messageLabel.text = "Словарь будет удален"
        notifView.timerLabel.text = "5"
        notifView.delegate = self
        self.view.addSubview(notifView)
        self.view.bringSubviewToFront(notifView)
        
        notifView.anchor(top: nil, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.notifView = notifView
    }
}

extension DictsViewController: IBottomNotificationViewDelegate {
    func onCancelButtonPressed() {
        self.dataSource.undoLastDeletion()
    }
    
    func onTimerDone() {
        self.dataSource.commitChanges()
    }
}
