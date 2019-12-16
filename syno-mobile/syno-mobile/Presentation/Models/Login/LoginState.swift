//
//  LoginState.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 23.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol ILoginState {
    var email: String {get}
    var password: String {get}
}

struct LoginState: ILoginState {
    let email: String
    
    let password: String
}

