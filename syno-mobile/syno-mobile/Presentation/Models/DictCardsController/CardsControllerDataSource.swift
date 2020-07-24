import Foundation
import UIKit
import CoreData

/// Protocol for delivering data to Collection View with cards
protocol ICardsControllerDataProvider {
    /// Generates `NSFetchedResultsController` for given dictionary
    func generateCardsControllerFRC(sourceDict: DbUserDictionary) -> NSFetchedResultsController<DbUserCard>
    
    /// Creates empty user card in given dict
    func createEmptyUserCard(sourceDict: DbUserDictionary, completionHandler: ((DbUserCard) -> Void)?)
    
    /// Deletes card with given object id
    func deleteManagedObject(object: NSManagedObject)
    
    /// Undos last deletion
    func undoLastDeletion()
    
    /// Commits all unsaved changes
    func commitChanges()
}

class CardsControllerDataProvider: ICardsControllerDataProvider {
    /// Service for performing actions with `CoreData`
    private var storageCoordinator: IStorageCoordinator
    /// Stores last deleted card's `CoreData` object id
    private var lastDeletedObject: NSManagedObject?
    /// Undo manager for mainContext
    private var undoManager: UndoManager?
    /// Stores uncommited deleted objects
    private var deletedObjects: [NSManagedObjectID] = []
    
    /**
     Creates new `CardsControllerDataProvider`
     - Parameter sotrageCoordinator:Service for performing actions with `CoreData`
     */
    init(storageCoordinator: IStorageCoordinator) {
        self.storageCoordinator = storageCoordinator
    }
    
    func createEmptyUserCard(sourceDict: DbUserDictionary, completionHandler: ((DbUserCard) -> Void)?) {
        self.storageCoordinator.stack.saveContext.performAndWait {
            let card = DbUserCard.insertUserCard(into: self.storageCoordinator.stack.saveContext)!
            card.sourceDictionary = self.storageCoordinator.stack.saveContext.object(with: sourceDict.objectID) as! DbUserDictionary
            card.timeCreated = Date()
            card.timeModified = Date()
            
            self.storageCoordinator.stack.performSave(with: self.storageCoordinator.stack.saveContext) {
                let objectId = card.objectID
                DispatchQueue.main.async {
                    completionHandler?(self.storageCoordinator.stack.mainContext.object(with: objectId) as! DbUserCard)
                }
            }
        }
    }
    
    func generateCardsControllerFRC(sourceDict: DbUserDictionary) -> NSFetchedResultsController<DbUserCard> {
        return NSFetchedResultsController(fetchRequest: DbUserCard.requestCardsFrom(sourceDict: sourceDict), managedObjectContext: storageCoordinator.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    /// Commits all unsaved changes
    func commitSaveContextChanges() {
        if deletedObjects.count > 0 {
            self.storageCoordinator.stack.saveContext.performAndWait {
                for el in deletedObjects {
                    self.storageCoordinator.stack.saveContext.delete( self.storageCoordinator.stack.saveContext.object(with: el))
                }
                deletedObjects = []
            }
        }
    }
    
    func deleteManagedObject(object: NSManagedObject) {
        self.storageCoordinator.stack.mainContext.undoManager = UndoManager()
        self.undoManager = self.storageCoordinator.stack.mainContext.undoManager
        self.undoManager?.beginUndoGrouping()
        self.storageCoordinator.stack.mainContext.delete(object)
        let objectId = object.objectID
        
        self.commitSaveContextChanges()
        
        self.deletedObjects.append(objectId)
    }
    
    func undoLastDeletion() {
        self.undoManager?.endUndoGrouping()
        self.undoManager?.undo()
        self.deletedObjects = []
    }
    
    func commitChanges() {
        commitSaveContextChanges()
        deletedObjects = []
        self.storageCoordinator.stack.performSave(with: self.storageCoordinator.stack.saveContext, completion: nil)
    }
}

/// Service protocol for presenting `DbUserCard` for current dictionary in `UICollectionVIew`
protocol ICardsControllerDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// `NSFetchedResultsController` for this dictionary cards
    var fetchedResultsController: NSFetchedResultsController<DbUserCard> { get set }
    /// Service for inner logic
    var viewModel: ICardsControllerDataProvider { get set }
    /// CollectionView selection event handler
    var delegate: ICardsDataSourceReactor? { get set }
    
    /// Performs fetch for `NSFetchedResultsController`
    func performFetch()
    
    /// Creates empty user card
    func createEmptyUserCard(completionHandler: ((DbUserCard) -> Void)?)
    
    func handleDeletion(indexPath: IndexPath)
    
    /// Undos last deleted card
    func undoLastDeletion()
    
    /// Commits unsaved changes
    func commitChanges()
}

/// Protocol for UICollectionView selection handling
protocol ICardsDataSourceReactor: class {
    /// Notifies when cell with given `DbUserCard` was selected
    func onSelectedItem(item: DbUserCard)
    
    /// Notifies when item was deleted
    func onItemDeleted()
}

class CardsControllerDataSource: NSObject, ICardsControllerDataSource {
    func handleDeletion(indexPath: IndexPath) {
        self.viewModel.deleteManagedObject(object: self.fetchedResultsController.object(at: indexPath))
        self.delegate?.onItemDeleted()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<DbUserCard> = {
        return self.viewModel.generateCardsControllerFRC(sourceDict: self.sourceDict)
    }()
    
    var viewModel: ICardsControllerDataProvider
    
    weak var delegate: ICardsDataSourceReactor?
    
    /// Dictionary which cards we are showing
    private var sourceDict: DbUserDictionary
    
    func performFetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let err {
            Logger.log("Cant perform fetch \(#function)")
            Logger.log(err.localizedDescription)
        }
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.cellId, for: indexPath) as? CardCollectionViewCell else { fatalError() }
        let cellData = self.fetchedResultsController.object(at: indexPath)
        
        cell.setup(configuration: cellData.toCellConfiguration())
        return cell
    }
    
    func createEmptyUserCard(completionHandler: ((DbUserCard) -> Void)?) {
        self.viewModel.createEmptyUserCard(sourceDict: self.sourceDict, completionHandler: completionHandler)
    }
    
    func undoLastDeletion() {
        self.viewModel.undoLastDeletion()
    }
    
    func commitChanges() {
        self.viewModel.commitChanges()
    }
    
    /**
     Creates new `CardsControllerDataSource`
     - Parameter viewModel: service for inner logic
     - Parameter sourceDict: Dictionary which cards to show
     */
    init(viewModel: ICardsControllerDataProvider, sourceDict: DbUserDictionary) {
        self.viewModel = viewModel
        self.sourceDict = sourceDict
    }
}

extension CardsControllerDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.onSelectedItem(item: self.fetchedResultsController.object(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmptyCardsCollectionViewHeader.headerId, for: indexPath)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let objCount = self.fetchedResultsController.fetchedObjects, objCount.count == 0 {
            return CGSize(width: collectionView.frame.width, height: 140)
        }
        return CGSize.zero
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Действия", children: [
                UIAction(title: "Удалить", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                    Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false) { (_) in
                        self.handleDeletion(indexPath: indexPath)
                    }
                })
            ])
            return menu
        }
    }
}
