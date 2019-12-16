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
}

class CardsControllerDataProvider: ICardsControllerDataProvider {
    
    private var storageCoordinator: IStorageCoordinator
    
    init(storageCoordinator: IStorageCoordinator) {
        self.storageCoordinator = storageCoordinator
    }
    
    func generateCardsControllerFRC(sourceDict: DbUserDictionary) -> NSFetchedResultsController<DbUserCard> {
        return NSFetchedResultsController(fetchRequest: DbUserCard.requestCardsFrom(sourceDict: sourceDict), managedObjectContext: storageCoordinator.stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}

protocol ICardsControllerDataSource: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var fetchedResultsController: NSFetchedResultsController<DbUserCard> { get set }
    
    var viewModel: ICardsControllerDataProvider { get set }
    
    var delegate: ICardsDataSourceReactor? { get set }
    
    func performFetch()
}

protocol ICardsDataSourceReactor: class {
    func onSelectedItem(item: DbUserCard)
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
        return cell
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
}
