import Foundation
import CoreData
import UIKit

/// Service for inner inner `CoreData` logic for `ICommonDictionaryControllerDataSource`
protocol IDictionaryControllerDataProvider {
    /// Generates new `NSFetchedResultsController`
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary>
    
    /// Undos deletion
    func undoLastChanges()
    
    /// Commits unsaved changes to `CoreData`
    func commitChanges()
    
    /// Temporary deletes object from `CoreData`
    func delete(object: NSManagedObject)
    
    /// Checks if user is authorized
    func isAuthorized() -> Bool
}

class DictionaryControllerDataProvider: IDictionaryControllerDataProvider {
    /// Service for perfroming actions with CoreData
    private var appUserManager: IStorageCoordinator
    /// Undo Manager for main context
    private var undoManager: UndoManager?
    /// Unsaved deleted objects
    private var deletedObjects: [NSManagedObjectID] = []
    
    /**
     Creates new `DictionaryControllerDataProvider`
     - Parameter appUserManager: Service for perfroming actions with CoreData
     */
    init(appUserManager: IStorageCoordinator) {
        self.appUserManager = appUserManager
    }
    
    func isAuthorized() -> Bool {
        var isAuth = false
        self.appUserManager.stack.saveContext.performAndWait {
            isAuth = self.appUserManager.getCurrentAppUser()?.email != "Guest"
        }
        return isAuth
    }
    
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary> {
        let userInMainContext = self.appUserManager.stack.mainContext.object(with: appUserManager.getCurrentAppUser()!.objectID) as! DbAppUser
        let frc = NSFetchedResultsController(fetchRequest: DbUserDictionary.requestSortedByName(owner: userInMainContext), managedObjectContext: self.appUserManager.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }
    
    func undoLastChanges() {
        self.undoManager?.endUndoGrouping()
        self.undoManager?.undo()
        self.deletedObjects = []
    }
    
    func commitChanges() {
        commitSaveContextChanges()
        deletedObjects = []
        self.appUserManager.stack.performSave(with: self.appUserManager.stack.saveContext, completion: nil)
    }
    
    /// Saves unsaved changes in CoreData
    func commitSaveContextChanges() {
        if deletedObjects.count > 0 {
            self.appUserManager.stack.saveContext.performAndWait {
                for el in deletedObjects {
                    self.appUserManager.stack.saveContext.delete( self.appUserManager.stack.saveContext.object(with: el))
                }
            }
            deletedObjects = []
        }
    }
    
    func delete(object: NSManagedObject) {
        self.appUserManager.stack.mainContext.undoManager = UndoManager()
        self.undoManager = self.appUserManager.stack.mainContext.undoManager
        self.undoManager?.beginUndoGrouping()
        self.appUserManager.stack.mainContext.delete(object)
        let objectId = object.objectID
        
        self.commitSaveContextChanges()
        
        self.deletedObjects.append(objectId)
    }
}

/// Service for common logic for deliverting `DbUserDictionary` objects
protocol ICommonDictionaryControllerDataSource {
    /// Current user dictionaries `NSFetchedResultsController`
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary> { get set }
    
    /// Service for delivering data
    var viewModel: IDictionaryControllerDataProvider { get set }
    
    /// Performs fetch from `CoreData`
    func performFetch()
}

/// Service for inner logic of `DictsController` and its Collection view renderer
protocol IDictionaryControllerTableViewDataSource: ICommonDictionaryControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// CollectionView Event handler
    var delegate: IDictionaryControllerReactor? { get set}
    
    /// Gets NewDictController
    func getNewDictController() -> UIViewController
    
    /// Gets AddShareViewController
    func addShareController() -> UIViewController
    
    /// Undos last deletion
    func undoLastDeletion()
   
    /// Commits all unsaved changes
    func commitChanges()
   
    /// Temporary deletes given object
    func delete(object: NSManagedObject)
    
    func delete(indexPath: IndexPath)
    
    func handleShare(indexPath: IndexPath)
    
    func handleDeletion(indexPath: IndexPath)
    
    /// Checks if user is authorized
    func isAuthorized() -> Bool
    
    /// Creates share for given dictionary
    func createShare(dict: DbUserDictionary)
}

/// `IDictionaryControllerTableViewDataSource` event handler
protocol IDictionaryControllerReactor: class {
    /// Shows given controller
    func showCardsController(controller: UIViewController)
    
    /// Notifies on item deletion
    func onItemDeleted()
    
    /// Show processView
    func showSharingProcessView()
    
    /// Show share's result AlertController
    func showSharingResultView(text: String, title: String)
}

class DictionaryControllerTableViewDataSource: NSObject, IDictionaryControllerTableViewDataSource {
    func handleShare(indexPath: IndexPath) {
        self.createShare(dict: self.fetchedResultsController.object(at: indexPath))
    }
    
    func handleDeletion(indexPath: IndexPath) {
        self.delegate?.onItemDeleted()
        self.delete(object: self.fetchedResultsController.object(at: indexPath))
    }
    
    func undoLastDeletion() {
        self.viewModel.undoLastChanges()
    }
    
    func commitChanges() {
        self.viewModel.commitChanges()
    }
    
    func delete(object: NSManagedObject) {
        self.viewModel.delete(object: object)
    }
    
    func delete(indexPath: IndexPath) {
        self.viewModel.delete(object: self.fetchedResultsController.object(at: indexPath))
    }
    
    func isAuthorized() -> Bool {
        return self.viewModel.isAuthorized()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in FRC")
        }
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            fatalError("No sections in FRC")
        }
        Logger.log("items in section : \(sections[section].numberOfObjects)")
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DictionaryCollectionViewCell.cellId, for: indexPath) as? DictionaryCollectionViewCell else { fatalError() }
        let cellData = self.fetchedResultsController.object(at: indexPath)
        
        cell.setup(config: cellData.toUserDictCellConfig())
        return cell
    }
    
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary>
    
    var viewModel: IDictionaryControllerDataProvider
    
    /// Service for sharing dictionaries
    var shareService: IDictShareService
    
    /// Assembly for creating ViewControllers
    private var presAssembly: IPresentationAssembly
    
    /// Event handler
    weak var delegate: IDictionaryControllerReactor?
    
    func performFetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let err {
            Logger.log("Cant perform fetch")
            Logger.log(err.localizedDescription)
        }
    }
    
    func getNewDictController() -> UIViewController {
        return self.presAssembly.newDictController()
    }
    
    func addShareController() -> UIViewController {
        return self.presAssembly.addShareController()
    }
    
    func createShare(dict: DbUserDictionary) {
        self.delegate?.showSharingProcessView()
        self.shareService.createShare(dictObjectID: dict.objectID) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let str):
                    self.delegate?.showSharingResultView(text: str, title: "Успех!")
                case .error(let err):
                    self.delegate?.showSharingResultView(text: err, title: "Ошибка!")
                }
            }
        }
    }
    
    /**
     Creates new `DictionaryControllerTableViewDataSource`
     - Parameter viewModel: service for data delivery
     - Parameter shareService: service for sharing dictionaries
     - Parameter presAssembly: service for creating ViewController
     */
    init(viewModel: IDictionaryControllerDataProvider, shareService: IDictShareService, presAssembly: IPresentationAssembly) {
        self.viewModel = viewModel
        self.fetchedResultsController = self.viewModel.generateDictControllerFRC()
        self.presAssembly = presAssembly
        self.shareService = shareService
    }
}

extension DictionaryControllerTableViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2-20, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.fetchedResultsController.object(at: indexPath)
        let controller = self.presAssembly.cardsViewController(sourceDict: item)
        
        self.delegate?.showCardsController(controller: controller)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Действия", children: [
                UIAction(title: "Удалить", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (_) in
                    self.handleDeletion(indexPath: indexPath)
                    }
                }),
                UIAction(title: "Поделиться", image: UIImage.init(systemName: "square.and.arrow.up"), handler: { (action) in
                    self.handleShare(indexPath: indexPath)
                })
            ])
            return menu
        }
    }
}
