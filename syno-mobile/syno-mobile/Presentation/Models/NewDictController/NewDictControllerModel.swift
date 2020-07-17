import Foundation

/// Dto for creating new dictionary
protocol INewDictControllerNewDictDto {
    /// name of new dictionary
    var name: String { get }
    /// language of new dictionary
    var language: String { get }
}

class NewDictControllerNewDictDto: INewDictControllerNewDictDto {
    var name: String
    
    var language: String
    
    /**
     Creates new `NewDictControllerNewDictDto`
     - Parameter name: name of new dictionary
     - Parameter language: language of new dictionary
     */
    init(name: String, language: String) {
        self.name = name
        self.language = language
    }
}

/// Protocol for service with inner logic of `NewDictController`
protocol INewOrEditDictControllerModel {
    /**
     Creates new dictionary
     - Parameter newDict: dto describing new dictionary data
     - Parameter completionHandler: completion callback
     */
    func saveNewDict(newDict: INewDictControllerNewDictDto, completionHandler: (() -> Void)?)
    
    func getDefaultName() -> String?
    
    func getDefaultLanguage() -> String?
}

class NewDictControllerModel: INewOrEditDictControllerModel {
    func getDefaultName() -> String? {
        return nil
    }
    
    func getDefaultLanguage() -> String? {
        return nil
    }
    
    /// Service for safely interacting with CoreData
    private var storageManager: IStorageCoordinator
    
    func saveNewDict(newDict: INewDictControllerNewDictDto, completionHandler: (() -> Void)?) {
        self.storageManager.stack.saveContext.performAndWait {
            let dict = DbUserDictionary.insertUserDict(into: self.storageManager.stack.saveContext)!
            dict.timeCreated = Date()
            dict.name = newDict.name
            dict.language = newDict.language
            dict.owner = try! self.storageManager.stack.saveContext.fetch(DbAppUser.requestActive()).first
            
            self.storageManager.stack.performSave(with: self.storageManager.stack.saveContext, completion: completionHandler)
        }
    }
    
    /**
     Creates new `NewDictControllerModel`
     - Parameter storageManager: Service for safely interacting with CoreData
     */
    init(storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
    }
}

class EditDictControllerModel: INewOrEditDictControllerModel {
    
    private let storageManager: IStorageCoordinator
    private var dictToEdit: DbUserDictionary
    
    init(storageManager: IStorageCoordinator, dictToEdit: DbUserDictionary) {
        self.storageManager = storageManager
        self.dictToEdit = dictToEdit
    }
    
    func saveNewDict(newDict: INewDictControllerNewDictDto, completionHandler: (() -> Void)?) {
        self.dictToEdit.managedObjectContext?.perform {
            self.dictToEdit.name = newDict.name
            self.dictToEdit.language = newDict.language
            
            if let context = self.dictToEdit.managedObjectContext {
                self.storageManager.stack.performSave(with: context, completion: completionHandler)
            }
        }
    }
    
    func getDefaultName() -> String? {
        var dictName: String?
        self.dictToEdit.managedObjectContext?.performAndWait {
            dictName = self.dictToEdit.name
        }
        
        return dictName
    }
    
    func getDefaultLanguage() -> String? {
        var defaultLang: String?
        self.dictToEdit.managedObjectContext?.performAndWait {
            defaultLang = self.dictToEdit.language
        }
        
        return defaultLang
    }
}
