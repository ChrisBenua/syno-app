//
//  DictionaryControllerTableViewDataSource.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol IDictionaryControllerDataProvider {
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary>
}

class DictionaryControllerDataProvider: IDictionaryControllerDataProvider {
    
    private var appUserManager: IStorageCoordinator
    
    init(appUserManager: IStorageCoordinator) {
        self.appUserManager = appUserManager
    }
    
    func generateDictControllerFRC() -> NSFetchedResultsController<DbUserDictionary> {
        let frc = NSFetchedResultsController(fetchRequest: DbUserDictionary.requestSortedByName(owner: appUserManager.getCurrentAppUser()!), managedObjectContext: self.appUserManager.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }
}

protocol ICommonDictionaryControllerDataSource {
    var fetchedResultsController: NSFetchedResultsController<DbUserDictionary> { get set }
    
    var viewModel: IDictionaryControllerDataProvider { get set }
    
    func performFetch()

}

protocol IDictionaryControllerTableViewDataSource: ICommonDictionaryControllerDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var delegate: IDictionaryControllerReactor? { get set}
}

protocol IDictionaryControllerReactor: class {
    func showCardsController(controller: UIViewController)
}

class DictionaryControllerTableViewDataSource: NSObject, IDictionaryControllerTableViewDataSource {
    
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
    
    init(viewModel: IDictionaryControllerDataProvider, presAssembly: IPresentationAssembly) {
        self.viewModel = viewModel
        self.fetchedResultsController = self.viewModel.generateDictControllerFRC()
        self.presAssembly = presAssembly
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
}
