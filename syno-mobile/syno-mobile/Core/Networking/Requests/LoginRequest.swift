//
//  LoginRequest.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

struct LoginDto: Encodable {
    let email: String
    let password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

class LoginRequest: IRequest {
    typealias Model = LoginRequest

    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.LoginEndPoint) {
                var request = URLRequest(url: url)
                request.method = .post
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.timeoutInterval = TimeInterval(exactly: 2000)!
                do {
                    request.httpBody = try JSONEncoder().encode(loginDto)
                } catch {
                    return nil
                }
                return request
            } else {
                return nil
            }
        }
    }

    let loginDto: LoginDto

    init(loginDto: LoginDto) {
        self.loginDto = loginDto
    }
}
