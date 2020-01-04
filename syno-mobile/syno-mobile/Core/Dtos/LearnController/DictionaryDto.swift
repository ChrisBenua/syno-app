//
//  DictionaryDto.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

class UserDictionaryDtoForTestController {
    let name: String?
    let cards: [UserCardDtoForLearnController]
    
    init(name: String?, cards: [UserCardDtoForLearnController]) {
        self.name = name
        self.cards = cards
    }
    
    static func initFrom(dictionary: DbUserDictionary) -> UserDictionaryDtoForTestController {
        let name = dictionary.name
        let cards = dictionary.getCards().map { (card) -> UserCardDtoForLearnController in
            return UserCardDtoForLearnController.initFrom(userCard: card)
        }
        
        return UserDictionaryDtoForTestController(name: name, cards: cards)
    }
}
