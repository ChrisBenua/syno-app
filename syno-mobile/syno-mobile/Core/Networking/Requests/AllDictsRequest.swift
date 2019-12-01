//
//  AllDicts.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 29.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

class AllDictsRequest: IRequest {
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.AllDicts) {
                var request = URLRequest(url: url)
                request.method = .get
                request.setValue("Bearer " + userDefaultManager.getToken()!, forHTTPHeaderField: "Authorization")
                
                return request
            }
            
            return nil
        }
    }
    
    private var userDefaultManager: IUserDefaultsManager
    
    init(manager: IUserDefaultsManager) {
        userDefaultManager = manager
    }
}
