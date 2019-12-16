//
//  RegistrationModel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 05.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IRegistrationReactor: class {
    func startedProcessingRegistration()
    
    func failed(error: String)
    
    func success()
}

protocol IRegistrationModel {
    func register()
    
    var state: IRegisterState { get }
    
    var reactor: IRegistrationReactor? { get set }
}

class RegistrationModel: IRegistrationModel {
    func register() {
        let dto = RegisterDto(email: self.state.email, password: self.state.password)
        self.reactor?.startedProcessingRegistration()
        
        self.registerService.register(registerDto: dto) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.reactor?.success()
                case .error(let str):
                    self.reactor?.failed(error: str)
                }
            }
        }
    }
    
    var state: IRegisterState
    
    weak var reactor: IRegistrationReactor?
    
    private var registerService: IRegisterService
    
    init(registerService: IRegisterService) {
        self.state = RegisterState()
        self.registerService = registerService
    }
}
