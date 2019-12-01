//
//  RequestsSettings.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

class RequestSettings {
    public static let URLPrefix = "http://localhost:8080"

    public static let LoginEndPoint = URLPrefix + "/api/auth/signin"
    
    public static let AllDicts = URLPrefix + "/api/dicts/my_all"
}
