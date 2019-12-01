//
//  LoginControllerServices.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation


protocol ILoginService {
    func login(loginDto: LoginDto, completionHandler: @escaping (Result<String>) -> Void)
}

class LoginService: ILoginService {
    private var requestSender: IRequestSender
    private var userDefaultsManager: IUserDefaultsManager
    
    init(requestSender: IRequestSender, userDefaultsManager: IUserDefaultsManager) {
        self.requestSender = requestSender
        self.userDefaultsManager = userDefaultsManager
    }
    
    func login(loginDto: LoginDto, completionHandler: @escaping (Result<String>) -> Void) {
        let request = RequestFactory.BackendRequests.login(loginDto: loginDto)
        
        self.requestSender.send(requestConfig: request) { (loginResponseResult) in
            switch (loginResponseResult) {
            case .error(let error):
                completionHandler(.error(error))
            case .success(let loginResp):
                self.userDefaultsManager.saveToken(token: loginResp.accessToken)
                self.userDefaultsManager.saveEmail(email: loginResp.email)
                completionHandler(.success(loginResp.email))
            }
        }
    }
}
