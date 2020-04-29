import Foundation
import UIKit
import CoreData

/// Protocol for default `NSFetchedResultsControllerDelegat`e for `UICollectionView`
protocol IDefaultCollectionViewFetchResultControllerDelegate: NSFetchedResultsControllerDelegate {
    /// Source collection view
    var collectionView: UICollectionView { get set }
}

class DictsControllerCollectionViewFRCDelegate: NSObject, IDefaultCollectionViewFetchResultControllerDelegate {
    var collectionView: UICollectionView
    
    /**
     Creates new `DictsControllerCollectionViewFRCDelegate`
     - Parameter collectionView: collectionView where to perform actions
     */
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Logger.log("Updated Controller")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        Logger.log("Type: \(type), indexPath: \(indexPath)")
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
        Logger.log("Type: \(type), indexPath: \(indexPath)")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
}
