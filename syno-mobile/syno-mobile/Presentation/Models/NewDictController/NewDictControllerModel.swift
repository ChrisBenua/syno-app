//
//  NewDictControllerModel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 10.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

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
        self.storageManager.stack.mainContext.performAndWait {
            let dict = DbUserDictionary.insertUserDict(into: self.storageManager.stack.mainContext)!
            dict.timeCreated = Date()
            dict.name = newDict.name
            dict.language = newDict.language
            dict.owner = storageManager.getCurrentAppUser()
            
            self.storageManager.stack.performSave(with: self.storageManager.stack.mainContext, completion: completionHandler)
        }
    }
    
    init(storageManager: IStorageCoordinator) {
        self.storageManager = storageManager
    }
}
