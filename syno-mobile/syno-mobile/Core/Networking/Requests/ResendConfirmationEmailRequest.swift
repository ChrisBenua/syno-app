//
//  ResendConfirmationEmailRequest.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 27.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation

class ResendConfirmationEmailRequest: IRequest {
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.resendConfirmationEmail(email: userDefaultsManager.getRegisterEmail()!)) {
                var request = URLRequest(url: url)
                request.method = .get
                request.setValue("Bearer " + userDefaultsManager.getToken()!, forHTTPHeaderField: "Authorization")
                
                return request
            }
            
            return nil
        }
    }
    
    private let userDefaultsManager: IUserDefaultsManager
    
    init(userDefaultsManager: IUserDefaultsManager) {
        self.userDefaultsManager = userDefaultsManager
    }
}
