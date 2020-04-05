//
//  CoreDataStack.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 30.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

protocol ICoreDataStack {
    
    var storeURL: URL { get }
    
    var managedObjectModel: NSManagedObjectModel { get set }
    
    var persistantStoreCoordinator: NSPersistentStoreCoordinator { get set }
    
    var mainContext: NSManagedObjectContext { get set }
   
    var masterContext: NSManagedObjectContext { get set }
    
    var saveContext: NSManagedObjectContext { get set }

    func performSave(with context: NSManagedObjectContext, completion: (() -> Void)?)
}

class CoreDataStack: ICoreDataStack {
    //public static var shared: CoreDataStack = CoreDataStack()
    
    var storeURL: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("storeURL: \(documentsURL.absoluteString)")
        return documentsURL.appendingPathComponent("Mystore12.sqlite")
    }
    
    let dataModelName = "Model"
    
    let dataModelExtension = "momd"
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: self.dataModelExtension)!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistantStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: nil)
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
                print("Save error \(err)")
            }
            
            if let parentContext = context.parent {
                self.performSave(with: parentContext, completion: completion)
            } else {
                //DispatchQueue.main.async {
                    completion?()
                //}
            }
            
        }
    
    }

}
