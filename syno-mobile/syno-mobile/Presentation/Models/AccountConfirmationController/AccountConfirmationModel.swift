//
//  AccountConfirmationModel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 26.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation

protocol IAccountConfirmationModelDelegate: class {
    func onSuccess()
    
    func onFailure(message: String)
}

protocol IAccountConfirmationModel {
    var delegate: IAccountConfirmationModelDelegate? { get set }
    
    func confirm(code: String)
}

class AccountConfirmationModel: IAccountConfirmationModel {
    weak var delegate: IAccountConfirmationModelDelegate?
    
    let userDefaultsManager: IUserDefaultsManager
    
    let requestSender: IRequestSender
    
    func confirm(code: String) {
        if let email = self.userDefaultsManager.getRegisterEmail() {
        let requestConfig = RequestFactory.BackendRequests.confirmAccount(dto: AccountConfirmationDto(email: email, code: code), userDefManager: self.userDefaultsManager)
            requestSender.send(requestConfig: requestConfig) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .error(let err):
                        self.delegate?.onFailure(message: err)
                    case .success:
                        self.delegate?.onSuccess()
                    }
                }
            }
        }
    }
    
    init(userDefaultsManager: IUserDefaultsManager, requestSender: IRequestSender) {
        self.userDefaultsManager = userDefaultsManager
        self.requestSender = requestSender
    }
}
