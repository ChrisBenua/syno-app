//
//  RegisterControllerServices.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 04.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IRegisterService {
    func register(registerDto: RegisterDto, completionHandler: ((Result<String>) -> Void)?)
}

class RegisterService: IRegisterService {
    
    private let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func register(registerDto: RegisterDto, completionHandler: ((Result<String>) -> Void)?) {
        requestSender.send(requestConfig: RequestFactory.BackendRequests.register(registerDto: registerDto)) { (resp) -> Void in
            switch resp {
            case .success(let model):
                completionHandler?(.success(model.message))
            case .error(let str):
                completionHandler?(.error(str))
            }
        }
    }
    
    
}
