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
protocol INewDictControllerModel {
    /**
     Creates new dictionary
     - Parameter newDict: dto describing new dictionary data
     - Parameter completionHandler: completion callback
     */
    func createNewDict(newDict: INewDictControllerNewDictDto, completionHandler: (() -> Void)?)
}

class NewDictControllerModel: INewDictControllerModel {
    /// Service for safely interacting with CoreData
    private var storageManager: IStorageCoordinator
    
    func createNewDict(newDict: INewDictControllerNewDictDto, completionHandler: (() -> Void)?) {
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
