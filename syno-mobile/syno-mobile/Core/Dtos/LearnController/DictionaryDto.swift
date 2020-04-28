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
