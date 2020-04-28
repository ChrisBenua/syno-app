import Foundation
import CoreData
import UIKit

protocol IDictionaryControllerDataProvider {
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary>
    
    func undoLastChanges()
    
    func commitChanges()
    
    func delete(object: NSManagedObject)
    
    func isAuthorized() -> Bool
    
}

class DictionaryControllerDataProvider: IDictionaryControllerDataProvider {
    
    private var appUserManager: IStorageCoordinator
    private var undoManager: UndoManager?
    private var deletedObjects: [NSManagedObjectID] = []
    
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

protocol ICommonDictionaryControllerDataSource {
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary> { get set }
    
    var viewModel: IDictionaryControllerDataProvider { get set }
    
    func performFetch()
}

protocol IDictionaryControllerTableViewDataSource: ICommonDictionaryControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var delegate: IDictionaryControllerReactor? { get set}
    
    func getNewDictController() -> UIViewController
    
    func addShareController() -> UIViewController
    
    func undoLastDeletion()
   
    func commitChanges()
   
    func delete(object: NSManagedObject)
    
    func isAuthorized() -> Bool
    
    func createShare(dict: DbUserDictionary)

}

protocol IDictionaryControllerReactor: class {
    func showCardsController(controller: UIViewController)
    
    func onItemDeleted()
    
    func showSharingProcessView()
    
    func showSharingResultView(text: String, title: String)
}

class DictionaryControllerTableViewDataSource: NSObject, IDictionaryControllerTableViewDataSource {
    func undoLastDeletion() {
        self.viewModel.undoLastChanges()
    }
    
    func commitChanges() {
        self.viewModel.commitChanges()
    }
    
    func delete(object: NSManagedObject) {
        self.viewModel.delete(object: object)
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
    
    var shareService: IDictShareService
    
    private var presAssembly: IPresentationAssembly
    
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
            let menu = UIMenu(title: "Actions", children: [
                UIAction(title: "Удалить", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (_) in
                        self.delegate?.onItemDeleted()
                        self.delete(object: self.fetchedResultsController.object(at: indexPath))
                    }
                }),
                UIAction(title: "Поделиться", image: UIImage.init(systemName: "square.and.arrow.up"), handler: { (action) in
                    self.createShare(dict: self.fetchedResultsController.object(at: indexPath))
                })
            ])
            return menu
        }
    }
}
