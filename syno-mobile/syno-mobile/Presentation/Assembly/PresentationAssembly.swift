//
//  PresentationAssembly.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 23.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IPresentationAssembly {
    func loginViewController() -> LoginViewController
    
    func registerViewController() -> RegistrationViewController
}

class PresentationAssembly: IPresentationAssembly {
    
    private let serviceAssembly: IServiceAssembly
    
    func loginViewController() -> LoginViewController {
        return LoginViewController(loginModel: LoginModel(loginService: serviceAssembly.loginService), registrationViewController: registerViewController())
    }
    
    func registerViewController() -> RegistrationViewController {
        return RegistrationViewController()
    }
    
    init(serviceAssembly: IServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
}
