//
//  CoreAssembly.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol ICoreAssembly {
    var requestSender: IRequestSender { get }

    var userDefaultsManager: IUserDefaultsManager { get }
    
    var storageManager: IStorageCoordinator { get }
}

class CoreAssembly: ICoreAssembly {
    let requestSender: IRequestSender = DefaultRequestSender()
    let userDefaultsManager: IUserDefaultsManager = UserDefaultsManager()
    let storageManager: IStorageCoordinator = StorageManager()
}
