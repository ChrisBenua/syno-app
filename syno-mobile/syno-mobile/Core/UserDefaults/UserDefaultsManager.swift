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

    func clearToken()

    func clearEmail()
    
    func getToken() -> String?
    
    func getEmail() -> String?
}

class UserDefaultsManager: IUserDefaultsManager {
    
    private static let accessTokenKey: String = "accessTokenKey"
    private static let userEmailKey: String = "userEmailKey"

    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsManager.accessTokenKey)
    }

    func saveEmail(email: String) {
        UserDefaults.standard.set(email, forKey: UserDefaultsManager.userEmailKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.accessTokenKey)
    }

    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.userEmailKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsManager.accessTokenKey)
    }

    func clearEmail() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsManager.userEmailKey)
    }
}
