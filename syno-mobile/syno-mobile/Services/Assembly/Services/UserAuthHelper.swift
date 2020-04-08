//
//  UserAuthHelper.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 07.04.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation

protocol IUserAuthHelper {
    func isAuthorized() -> Bool
}

class UserAuthHelper: IUserAuthHelper {
    private var userDefManager: IUserDefaultsManager
    
    func isAuthorized() -> Bool {
        let curr = Int(Date().timeIntervalSince1970)
        if ((userDefManager.getTokenTimestamp() == 0) || (curr - userDefManager.getTokenTimestamp() > 86300)) {
            return false
        }
        
        return true
    }
    
    init(userDefManager: IUserDefaultsManager) {
        self.userDefManager = userDefManager
    }
}
