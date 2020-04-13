//
//  CardsControllerDataSource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 12.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ICardsControllerDataProvider {
    func generateCardsControllerFRC(sourceDict: DbUserDictionary) -> NSFetchedResultsController<DbUserCard>
    
    func createEmptyUserCard(sourceDict: DbUserDictionary, completionHandler: ((DbUserCard) -> Void)?)
    
    func deleteManagedObject(object: NSManagedObject)
    
    func undoLastDeletion()
    
    func commitChanges()
}

class CardsControllerDataProvider: ICardsControllerDataProvider {
    
    private var storageCoordinator: IStorageCoordinator
    private var lastDeletedObject: NSManagedObject?
    private var undoManager: UndoManager?
    
    init(storageCoordinator: IStorageCoordinator) {
        self.storageCoordinator = storageCoordinator
    }
    
    func createEmptyUserCard(sourceDict: DbUserDictionary, completionHandler: ((DbUserCard) -> Void)?) {
        let card = DbUserCard.insertUserCard(into: self.storageCoordinator.stack.mainContext)!
        card.sourceDictionary = sourceDict
        card.timeCreated = Date()
        
        self.storageCoordinator.stack.performSave(with: self.storageCoordinator.stack.mainContext) {
            completionHandler?(card)
        }
    }
    
    func generateCardsControllerFRC(sourceDict: DbUserDictionary) -> NSFetchedResultsController<DbUserCard> {
        return NSFetchedResultsController(fetchRequest: DbUserCard.requestCardsFrom(sourceDict: sourceDict), managedObjectContext: storageCoordinator.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func deleteManagedObject(object: NSManagedObject) {
        lastDeletedObject = object
        self.storageCoordinator.stack.mainContext.undoManager = UndoManager()
        self.undoManager = self.storageCoordinator.stack.mainContext.undoManager
        self.undoManager?.beginUndoGrouping()
        self.storageCoordinator.stack.mainContext.delete(object)
    }
    
    func undoLastDeletion() {
        if let obj = lastDeletedObject {
            self.undoManager?.endUndoGrouping()
            self.undoManager?.undo()
        }
    }
    
    func commitChanges() {
        self.storageCoordinator.stack.performSave(with: self.storageCoordinator.stack.mainContext, completion: nil)
    }
}

protocol ICardsControllerDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var fetchedResultsController: NSFetchedResultsController<DbUserCard> { get set }
    
    var viewModel: ICardsControllerDataProvider { get set }
    
    var delegate: ICardsDataSourceReactor? { get set }
    
    func performFetch()
    
    func createEmptyUserCard(completionHandler: ((DbUserCard) -> Void)?)
    
    func undoLastDeletion()
    
    func commitChanges()
}

protocol ICardsDataSourceReactor: class {
    func onSelectedItem(item: DbUserCard)
    
    func onItemDeleted()
}

class CardsControllerDataSource: NSObject, ICardsControllerDataSource {
    lazy var fetchedResultsController: NSFetchedResultsController<DbUserCard> = {
        return self.viewModel.generateCardsControllerFRC(sourceDict: self.sourceDict)
    }()
    
    var viewModel: ICardsControllerDataProvider
    
    weak var delegate: ICardsDataSourceReactor?
    
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
        print("Dequeuing cell at: \(indexPath)")
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
    
    init(viewModel: ICardsControllerDataProvider, sourceDict: DbUserDictionary) {
        self.viewModel = viewModel
        self.sourceDict = sourceDict
    }
}

extension CardsControllerDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 50)
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
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let menu = UIMenu(title: "Actions", children: [
                UIAction(title: "Delete", image: UIImage.init(systemName: "trash.fill"), attributes: .destructive, handler: { (action) in
                    print("Action happened!!!")
                    self.viewModel.deleteManagedObject(object: self.fetchedResultsController.object(at: indexPath))
                    self.delegate?.onItemDeleted()
                })
            ])
            return menu
        }
    }
}
