//
//  EmailForConfirmationModel.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 27.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation

protocol IEmailConfirmationModelDelegate: class {
    func onSuccess()
    
    func onError(error: String)
}

protocol IEmailConfirmationModel {
    var delegate: IEmailConfirmationModelDelegate? { get set }
    
    func resendEmailConfirmation(email: String)
}

class EmailConfirmationModel: IEmailConfirmationModel {
    weak var delegate: IEmailConfirmationModelDelegate?
    
    private let requestSender: IRequestSender
    
    private let userDefaultsManager: IUserDefaultsManager
    
    func resendEmailConfirmation(email: String) {
        userDefaultsManager.saveRegisterEmail(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
        requestSender.send(requestConfig: RequestFactory.BackendRequests.resendConfirmationEmail(userDefManager: self.userDefaultsManager)) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .error(let err):
                    self.delegate?.onError(error: err)
                case .success:
                    self.delegate?.onSuccess()
                }
            }
        }
    }
    
    init(requestSender: IRequestSender, userDefaultsManager: IUserDefaultsManager) {
        self.requestSender = requestSender
        self.userDefaultsManager = userDefaultsManager
    }
}

