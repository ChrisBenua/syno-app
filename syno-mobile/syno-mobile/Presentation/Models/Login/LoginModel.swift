//
//  LoginModel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol ILoginModel {
    func login(loginState: ILoginState)

    var controller: ILoginReactor? { get set }
}

class LoginModel: ILoginModel {
    var controller: ILoginReactor?

    private let loginService: ILoginService

    init(loginService: ILoginService) {
        self.loginService = loginService
    }

//    func kek() {
//        var conf = RequestFactory.BackendRequests.allDictsRequest(userDefaultsManager: UserDefaultsManager())
//        DefaultRequestSender().send(requestConfig: conf) { (result) in
//            switch result {
//            case .success(let dicts):
//                print(dicts.count)
//            case .error(let str):
//                print(str)
//            }
//        }
//    }
    
    func login(loginState: ILoginState) {
        let loginDto = LoginDto(email: loginState.email, password: loginState.password)
        controller?.onStartedProcessingLogin()
        loginService.login(loginDto: loginDto) { (result) -> Void in
            switch (result) {
            case .error( _):
                DispatchQueue.main.async {
                    self.controller?.onFailedLogin()
                }
            case .success(let email):
                DispatchQueue.main.async {
                    self.controller?.onSuccessfulLogin(email: email)
                }
            }
        }
    }
}
