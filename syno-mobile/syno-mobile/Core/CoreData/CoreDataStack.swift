import Foundation
import CoreData

/// Service protocol for configuring `CoreData`
protocol ICoreDataStack {
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
    @UserDefaultsBacked(key: "didMigrate")
    private var didMigrate: Bool = false

    var oldStoreURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeUrl = documentsURL.appendingPathComponent("Mystore12.sqlite")
        Logger.log("oldStoreURL: \(storeUrl.absoluteString)")
        return storeUrl
    }

    var newStoreURL: URL {
      let fileManager = FileManager.default
      let appGroupStoreURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.syno.rawValue)!.appendingPathComponent("Mystore12.sqlite")
      Logger.log("new storeURL: \(appGroupStoreURL.absoluteString)")
      return appGroupStoreURL
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
          if didMigrate {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.newStoreURL, options: options)
          } else {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.oldStoreURL, options: options)
          }
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

    init() {
      if !didMigrate {
        migrate()
      }
    }
    
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

    private func migrate() {
      let coordinator = persistantStoreCoordinator
      if let oldStore = coordinator.persistentStore(for: oldStoreURL) {
        do {
          try coordinator.migratePersistentStore(oldStore, to: newStoreURL, options: nil, withType: NSSQLiteStoreType)
          self.didMigrate = true
        } catch let error {
          print(error)
        }
      }
    }
}

@propertyWrapper struct UserDefaultsBacked<Value> {
  var wrappedValue: Value {
    get {
      let value = storage.value(forKey: key) as? Value
      return value ?? defaultValue
    }
    set {
      storage.setValue(newValue, forKey: key)
    }
  }

  private let key: String
  private let defaultValue: Value
  private let storage: UserDefaults

  init(
    wrappedValue defaultValue: Value,
    key: String,
    storage: UserDefaults = .standard
  ) {
    self.defaultValue = defaultValue
    self.key = key
    self.storage = storage
  }
}
