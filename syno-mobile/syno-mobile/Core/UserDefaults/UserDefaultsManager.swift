//
//  UserDefaultsManager.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 27.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IUserDefaultsManager {
    func saveToken(token: String)
    
    func saveEmail(email: String)
    
    func saveTokenTimestamp(date: Date)

    func clearToken()

    func clearEmail()
    
    func getToken() -> String?
    
    func getEmail() -> String?
    
    func setNetworkMode(isActive: Bool)
    
    func getNetworkMode() -> Bool
    
    func getTokenTimestamp() -> Int
}

class UserDefaultsManager: IUserDefaultsManager {
    
    private static let accessTokenKey: String = "accessTokenKey"
    private static let userEmailKey: String = "userEmailKey"
    private static let networkModeKey: String = "networkModeKey"
    private static let accessTokenTimestampKey: String = "accessTokenTimestampKey"

    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsManager.accessTokenKey)
    }

    func saveEmail(email: String) {
        UserDefaults.standard.set(email, forKey: UserDefaultsManager.userEmailKey)
    }
    
    func saveTokenTimestamp(date: Date) {
        let timestamp: Int = Int(date.timeIntervalSince1970)
        UserDefaults.standard.set(timestamp, forKey: UserDefaultsManager.accessTokenTimestampKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.accessTokenKey)
    }

    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.userEmailKey)
    }
    
    func getTokenTimestamp() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsManager.accessTokenTimestampKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsManager.accessTokenKey)
    }

    func clearEmail() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsManager.userEmailKey)
    }
    
    func setNetworkMode(isActive: Bool) {
        UserDefaults.standard.set(isActive, forKey: UserDefaultsManager.networkModeKey)
    }
    
    func getNetworkMode() -> Bool {
        return (UserDefaults.standard.object(forKey: UserDefaultsManager.networkModeKey) as? Bool) ?? true
    }
}
