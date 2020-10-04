import Foundation
import CoreData
import UIKit

protocol ITrashDictionaryControllerDataProvider {
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary>

    func deletePermanently(objectId: NSManagedObjectID)
    
    func restore(objectId: NSManagedObjectID)
    
    func clearTrash()
}

protocol ITrashDictionaryControllerReactor: class {
    func showCardsController(controller: UIViewController)
}

protocol ITrashDictionaryControllerTableViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    var delegate: ITrashDictionaryControllerReactor? { get set }
    
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary> { get }
    
    var dataProvider: ITrashDictionaryControllerDataProvider { get }
    
    func performFetch()
    
    func handleRestore(indexPath: IndexPath)

    func handleDeletion(indexPath: IndexPath)
    
    func handleClear()
}

class TrashDictionaryControllerDataProvider: ITrashDictionaryControllerDataProvider {
    private var storageCoordinator: IStorageCoordinator
    private var frc: NSFetchedResultsController<DbUserDictionary>!
    
    init(storageCoordinator: IStorageCoordinator) {
        self.storageCoordinator = storageCoordinator
    }
    
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary> {
        let userInMainContext = self.storageCoordinator.stack.mainContext.object(with: storageCoordinator.getCurrentAppUser()!.objectID) as! DbAppUser
        
        frc = NSFetchedResultsController(fetchRequest: DbUserDictionary.requestDeletedSortedByDate(owner: userInMainContext), managedObjectContext: self.storageCoordinator.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }
    
    func deletePermanently(objectId: NSManagedObjectID) {
        let context = self.storageCoordinator.stack.saveContext
        
        context.performAndWait {
            context.delete(context.object(with: objectId))
        }
        self.storageCoordinator.stack.performSave(with: context, completion: nil)
    }
    
    func restore(objectId: NSManagedObjectID) {
        let context = self.storageCoordinator.stack.saveContext
        
        context.performAndWait {
            let dict = context.object(with: objectId) as? DbUserDictionary
            dict?.wasDeletedManually = false
        }
        self.storageCoordinator.stack.performSave(with: context, completion: nil)
    }
    
    func clearTrash() {
        let context = self.storageCoordinator.stack.saveContext
        for el in frc.fetchedObjects ?? [] {
            context.performAndWait {
                context.delete(context.object(with: el.objectID))
            }
        }
        self.storageCoordinator.stack.performSave(with: context, completion: nil)
    }
}

class TrashDictionaryControllerTableViewDataSource: NSObject, ITrashDictionaryControllerTableViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: ITrashDictionaryControllerReactor?
    
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary>
    
    var dataProvider: ITrashDictionaryControllerDataProvider
    
    var presentationAssembly: IPresentationAssembly
    
    init(presAssembly: IPresentationAssembly, dataProvider: ITrashDictionaryControllerDataProvider) {
        self.presentationAssembly = presAssembly
        self.dataProvider = dataProvider
        self.fetchedResultsController = dataProvider.generateDictControllerFRC()
    }
    
    func performFetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let err {
            Logger.log("Cant perform fetch in \(TrashDictionaryControllerTableViewDataSource.self) \(#function)")
            Logger.log(err.localizedDescription)
        }
    }
    
    func handleRestore(indexPath: IndexPath) {
        self.dataProvider.restore(objectId: self.fetchedResultsController.object(at: indexPath).objectID)
    }
    
    func handleDeletion(indexPath: IndexPath) {
        self.dataProvider.deletePermanently(objectId: self.fetchedResultsController.object(at: indexPath).objectID)
    }
    
    func handleClear() {
        self.dataProvider.clearTrash()
    }
}


extension TrashDictionaryControllerTableViewDataSource {
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
        let controller = self.presentationAssembly.cardsViewController(sourceDict: item)
        
        self.delegate?.showCardsController(controller: controller)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmptyDictTrashCollectionViewHeader.headerId, for: indexPath)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let objCount = self.fetchedResultsController.fetchedObjects, objCount.count == 0 {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        return CGSize.zero
    }
    
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Действия", children: [
                UIAction(title: "Восстановить", image: UIImage.init(systemName: "arrow.counterclockwise"), handler: { (action) in
                    Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (_ ) in
                        self.handleRestore(indexPath: indexPath)
                    }
                }),
                UIAction(title: "Удалить", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (_) in
                    self.handleDeletion(indexPath: indexPath)
                    }
                }),
            ])
            return menu
        }
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(collection: collectionView, for: configuration)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(collection: collectionView, for: configuration)
    }

    @available(iOS 13.0, *)
    private func makeTargetedPreview(collection: UICollectionView, for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        // Get the cell for the index of the model
        guard let cell = collection.cellForItem(at: indexPath) as? DictionaryCollectionViewCell else { return nil }
        // Set parameters to a circular mask and clear background
        let parameters = UIPreviewParameters()
        
        return UITargetedPreview(view: cell.baseShadowView.containerView, parameters: parameters)
    }
}

