import Foundation
import CoreData

/// DTO for passing copy of `DbUserCard` to `LearnViewController`
class UserCardDtoForLearnController {
    let translatedWord: String?
    let cardManagedObjectId: NSManagedObjectID
    let translations: [UserTranslationDtoForLearnController]
    
    /// Creates new `UserCardDtoForLearnController`
    init(translatedWord: String?, cardManagedObjectId: NSManagedObjectID, translations: [UserTranslationDtoForLearnController]) {
        self.translatedWord = translatedWord
        self.cardManagedObjectId = cardManagedObjectId
        self.translations = translations
    }
    
    /// Creates new `UserCardDtoForLearnController` from given `DbUserCard`
    static func initFrom(userCard: DbUserCard) -> UserCardDtoForLearnController {
        let translations = userCard.getTranslations().reversed().map({ (translation: DbTranslation) -> UserTranslationDtoForLearnController in
            return UserTranslationDtoForLearnController.initFrom(translation: translation)
        })
        return UserCardDtoForLearnController(translatedWord: userCard.translatedWord, cardManagedObjectId: userCard.objectID, translations: translations)
    }
}
