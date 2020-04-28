import Foundation

protocol INewDictControllerNewDictDto {
    var name: String { get }
    var language: String { get }
}

class NewDictControllerNewDictDto: INewDictControllerNewDictDto {
    var name: String
    
    var language: String
    
    init(name: String, language: String) {
        self.name = name
        self.language = language
    }
}

protocol INewDictControllerModel {
    func createNewDict(newDict: INewDictControllerNewDictDto, completionHandler: (() -> Void)?)
}

class NewDictControllerModel: INewDictControllerModel {
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
    
    init(storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
    }
}
