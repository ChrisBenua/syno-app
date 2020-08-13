import Foundation
import CoreData

/// Service protocol for configuring `CoreData`
protocol ICoreDataStack {
    /// `URL` for database
    var storeURL: URL { get }
    /// Stores object model
    var managedObjectModel: NSManagedObjectModel { get set }
    /// Main `NSPersistentStoreCoordinator` for `managedObjectModel`
    var persistantStoreCoordinator: NSPersistentStoreCoordinator { get set }
    /// `NSManagedObjectContext` for UI thread
    var mainContext: NSManagedObjectContext { get set }
    /// `NSManagedObjectContext` for saving in background thread and commiting to `persistantStoreCoordinator`
    var masterContext: NSManagedObjectContext { get set }
    /// `NSManagedObjectContext` for saving in bacground thread
    var saveContext: NSManagedObjectContext { get set }

    /**
     Perfomes save in given context and its parents
     - Parameter context: Context which should be saved
     - Parameter completion: Saving process completion callback
     */
    func performSave(with context: NSManagedObjectContext, completion: (() -> Void)?)
}

class CoreDataStack: ICoreDataStack {
    var storeURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        Logger.log("storeURL: \(documentsURL.absoluteString)")
        return documentsURL.appendingPathComponent("Mystore12.sqlite")
    }
    /// Name of `xcdatamodeld` file
    let dataModelName = "Model"
    /// Default extension of `xcdatamodeld` file
    let dataModelExtension = "momd"
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: self.dataModelExtension)!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: options)
        } catch let err {
            assert(false)
        }
        
        return coordinator
    }()
    
    lazy var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterContext.persistentStoreCoordinator = self.persistantStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        
        return masterContext
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        
        return mainContext
    }()
    
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        saveContext.parent = self.mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        
        return saveContext
    }()
    
    func performSave(with context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        context.perform {
            guard context.hasChanges else {
                completion?()
                return
            }
            
            do {
                try context.save()
            } catch let err {
                Logger.log("Save error \(err)")
            }
            
            if let parentContext = context.parent {
                self.performSave(with: parentContext, completion: completion)
            } else {
                completion?()
            }
        }
    }
}
