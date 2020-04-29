import Foundation

/// DTO for passing `DbUserDictionary` copy to `LearnViewController`
class UserDictionaryDtoForTestController {
    let name: String?
    let cards: [UserCardDtoForLearnController]
    
    /// Creates new `UserDictionaryDtoForTestController`
    init(name: String?, cards: [UserCardDtoForLearnController]) {
        self.name = name
        self.cards = cards
    }
    
    /// Creates new `UserDictionaryDtoForTestController` from given `DbUserDictionary`
    static func initFrom(dictionary: DbUserDictionary) -> UserDictionaryDtoForTestController {
        let name = dictionary.name
        let cards = dictionary.getCards().map { (card) -> UserCardDtoForLearnController in
            return UserCardDtoForLearnController.initFrom(userCard: card)
        }
        
        return UserDictionaryDtoForTestController(name: name, cards: cards)
    }
}
