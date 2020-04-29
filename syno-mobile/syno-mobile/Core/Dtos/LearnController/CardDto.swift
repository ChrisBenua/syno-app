import Foundation

/// DTO for passing copy of `DbUserCard` to `LearnViewController`
class UserCardDtoForLearnController {
    let translatedWord: String?
    let cards: [UserTranslationDtoForLearnController]
    
    /// Creates new `UserCardDtoForLearnController`
    init(translatedWord: String?, cards: [UserTranslationDtoForLearnController]) {
        self.translatedWord = translatedWord
        self.cards = cards
    }
    
    /// Creates new `UserCardDtoForLearnController` from given `DbUserCard`
    static func initFrom(userCard: DbUserCard) -> UserCardDtoForLearnController {
        let translations = userCard.translations!.toArray()!.map({ (translation: DbTranslation) -> UserTranslationDtoForLearnController in
            return UserTranslationDtoForLearnController.initFrom(translation: translation)
        })
        return UserCardDtoForLearnController(translatedWord: userCard.translatedWord, cards: translations)
    }
}
