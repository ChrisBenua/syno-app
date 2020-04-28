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
