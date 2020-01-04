//
//  CardDto.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

class UserCardDtoForLearnController {
    let translatedWord: String?
    let cards: [UserTranslationDtoForLearnController]
    
    init(translatedWord: String?, cards: [UserTranslationDtoForLearnController]) {
        self.translatedWord = translatedWord
        self.cards = cards
    }
    
    static func initFrom(userCard: DbUserCard) -> UserCardDtoForLearnController {
        let translations = userCard.translations!.toArray()!.map({ (translation: DbTranslation) -> UserTranslationDtoForLearnController in
            return UserTranslationDtoForLearnController.initFrom(translation: translation)
        })
        return UserCardDtoForLearnController(translatedWord: userCard.translatedWord, cards: translations)
    }
}
