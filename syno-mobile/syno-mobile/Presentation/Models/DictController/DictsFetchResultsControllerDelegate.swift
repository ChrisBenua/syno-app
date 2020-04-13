//
//  DictsFetchResultsControllerDelegate.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol IDefaultCollectionViewFetchResultControllerDelegate: NSFetchedResultsControllerDelegate {
    var collectionView: UICollectionView { get set }
}

class DictsControllerCollectionViewFRCDelegate: NSObject, IDefaultCollectionViewFetchResultControllerDelegate {
    var collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.log("Updated Controller")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Type: \(type), indexPath: \(indexPath)")
        if (type == .delete) {
            if indexPath != nil {
                self.collectionView.deleteItems(at: [indexPath!])
            } else {
                self.collectionView.reloadData()
            }
        } else if (type == .insert) {
            if indexPath != nil {
                self.collectionView.insertItems(at: [indexPath!])
            } else {
                self.collectionView.reloadData()
            }
        } else if (type == .move) {
            if indexPath != nil {
                self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            } else {
                self.collectionView.reloadData()
            }
        } else if (type == .update) {
            if indexPath != nil {
                self.collectionView.reloadItems(at: [indexPath!])
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
}


class DefaultCollectionViewFRCDelegate: NSObject, IDefaultCollectionViewFetchResultControllerDelegate {
    var collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.log("Updated Controller")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Type: \(type), indexPath: \(indexPath)")
//        if (type == .delete) {
//            if indexPath != nil {
//                self.collectionView.deleteItems(at: [indexPath!])
//            }
//        } else if (type == .insert) {
//            if indexPath != nil {
//                self.collectionView.reloadData()
//            }
//        } else if (type == .move) {
//            if indexPath != nil {
//                self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
//            }
//        } else if (type == .update) {
//            if indexPath != nil {
//                self.collectionView.reloadItems(at: [indexPath!])
//            }
//        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
}
