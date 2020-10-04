//
//  TransferGuestDictsToNewAccount.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 29.06.2020.
//  Copyright © 2020 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

protocol ITransferGuestDictsToNewAccountDelegate: class {
    func onSuccess()
    
    func onFailure(err: String)
}

protocol ITransferGuestDictsToNewAccount {
    var delegate: ITransferGuestDictsToNewAccountDelegate? { get set }
    
    func transferToUser(newUserEmail: String)
    
    func needToTransferDictsFromGuest() -> Bool
}

class TransferGuestDictsToNewAccount: ITransferGuestDictsToNewAccount {
    weak var delegate: ITransferGuestDictsToNewAccountDelegate?
    
    private let storageManager: IStorageCoordinator
    
    private let dictionaryFetchService: IUserDictionaryFetchService
    
    func transferToUser(newUserEmail: String) {
        var newUser: DbAppUser!
        self.storageManager.stack.mainContext.performAndWait {
            do {
            newUser = try self.storageManager.stack.mainContext.fetch(DbAppUser.requestByEmail(email: newUserEmail)).first!
                let arr = try self.storageManager.stack.mainContext.fetch(DbAppUser.requestByEmail(email: "Guest"))
                if let guest = arr.first {
                    var dicts: [DbUserDictionary] = guest.getDictionaries(includeDeletedManually: false)
//                    dicts = dicts.filter{ !$0.wasDeletedManually }
                    let dictDto: [GetDictionaryResponseDto] = dicts.map { (el) -> GetDictionaryResponseDto in
                        let cards: [DbUserCard] = (el.userCards?.toArray() ?? [])
                        return GetDictionaryResponseDto(id: el.serverId, name: el.name ?? "", timeCreated: el.timeCreated ?? Date(), timeModified: el.timeModified ?? Date(), language: el.language, userCards: cards.map({ (card) -> GetCardResponseDto in
                            let trans = card.getTranslations()
                            return GetCardResponseDto(id: card.serverId, translatedWord: card.translatedWord ?? "", timeCreated: card.timeCreated ?? Date(), timeModified: card.timeModified ?? Date(), translations: trans.map({ (translation) -> GetTranslationDto in
                                return GetTranslationDto(id: translation.serverId, translation: translation.translation ?? "", transcription: translation.transcription ?? "", comment: translation.comment ?? "", usageSample: translation.usageSample ?? "", timeCreated: translation.timeCreated ?? Date(), timeModified: translation.timeModified ?? Date(), pin: translation.pin!)
                            }), pin: card.pin!)
                        }), pin: el.pin!)
                    }
                    dictionaryFetchService.updateDicts(dicts: dictDto, owner: newUser, shouldDelete: false) {
                        DispatchQueue.main.async {
                            self.delegate?.onSuccess()
                        }
                    }
                }
            } catch let err {
                delegate?.onFailure(err: err.localizedDescription)
            }
        }
    }
    
    func needToTransferDictsFromGuest() -> Bool {
        var need = false
        self.storageManager.stack.mainContext.performAndWait {
            do {
                let arr2 = try self.storageManager.stack.mainContext.fetch(DbAppUser.requestActive())
                let arr = try self.storageManager.stack.mainContext.fetch(DbAppUser.requestByEmail(email: "Guest"))
                if arr2.count > 0 {
                    if (arr2.first!.getDictionaries(includeDeletedManually: false).count ?? 0) > 0 {
                        need = false
                        return
                    }
                }
                
                if arr.count == 0 {
                    need = false
                } else {
                    need = (arr.first?.dictionaries?.count ?? 0) != 0
                }
                
            } catch let err {
                Logger.log("Error in \(#function) \(#file) \(err.self):\n \(err.localizedDescription)")
            }
        }
        return need
    }
    
    init(storageManager: IStorageCoordinator, dictionaryFetchService: IUserDictionaryFetchService) {
        self.storageManager = storageManager
        self.dictionaryFetchService = dictionaryFetchService
    }
}
