//
//  ServiceAssembly.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol IServiceAssembly {
    var loginService: ILoginService { get }
}

class ServiceAssembly: IServiceAssembly {
    private let coreAssembly: ICoreAssembly
    
    var loginService: ILoginService
    
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
        self.loginService = LoginService(requestSender: coreAssembly.requestSender, userDefaultsManager: coreAssembly.userDefaultsManager)
    }
}
