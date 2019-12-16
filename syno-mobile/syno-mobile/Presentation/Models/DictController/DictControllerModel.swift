//
//  DictControllerModel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IDictControllerModel {
    func initialFetch()
}

class DictControllerModel: IDictControllerModel {
    private let userDictsFetchService: IUserDictionaryFetchService
    private let requestSender: IRequestSender
    private let userDefManager: IUserDefaultsManager
    private let appUserManager: IAppUserStorageManager
    
    init(userDictsFetchService: IUserDictionaryFetchService, sender: IRequestSender, userDefManager: IUserDefaultsManager, appUserManager: IAppUserStorageManager) {
        self.userDictsFetchService = userDictsFetchService
        self.requestSender = sender
        self.userDefManager = userDefManager
        self.appUserManager = appUserManager
    }
    
    func initialFetch() {
        self.requestSender.send(requestConfig: RequestFactory.BackendRequests.allDictsRequest(userDefaultsManager: self.userDefManager)) { (result) in
            switch result {
            case .success(let dtos):
                let user = self.appUserManager.getCurrentAppUser()!
                self.userDictsFetchService.updateDicts(dicts: dtos, owner: user, completion: nil)
            case .error(let str):
                Logger.log("Error while doing init fetch in dicts controller: \(#function)")
                Logger.log("Error: \(str)\n")
            }
        }
    }
}
