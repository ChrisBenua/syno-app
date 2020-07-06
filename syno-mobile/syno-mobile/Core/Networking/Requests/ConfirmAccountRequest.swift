//
//  ConfirmAccountRequest.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation

class AccountConfirmationDto: Encodable {
    let email: String
    let code: String
    
    init(email: String, code: String) {
        self.email = email
        self.code = code
    }
}

class ConfirmAccountRequest: IRequest {
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.confirmAccount) {
                var request = URLRequest(url: url)
                request.method = .post
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                
                do {
                    let encoder = JSONEncoder()
                    encoder.keyEncodingStrategy = .convertToSnakeCase
                    encoder.dateEncodingStrategy = .formatted(.iso8601Full)
                    request.httpBody = try encoder.encode(dto)
                } catch {
                    return nil
                }
                
                return request
            }
            
            return nil
        }
    }
    
    let userDefaultsManager: IUserDefaultsManager
    
    let dto: AccountConfirmationDto
    
    init(userDefaultsManager: IUserDefaultsManager, dto: AccountConfirmationDto) {
        self.userDefaultsManager = userDefaultsManager;
        self.dto = dto
    }
    
}
