import Foundation

///DTO for updating `DbUserDictionary` on server
class UpdateUserDictionaryDto: Codable {
    let pin: String
    
    let name: String
    
    let language: String
    
    let timeCreated: Date?
    
    let timeModified: Date?
    
    let userCards: [UpdateUserCardDto]
    
    /**
     Creates new `UpdateUserDictionaryDto`
     - Parameters:
        - pin: unique `DbUserDictionary` id
        - name: dictionary name
        - language: dictionary language
        - timeCreated: time when `DbUserDictionary` was created
        - timeModified: time when `UpdateUserDictionaryDto` was modified
        - userCards: list of dictionaries cards
     */
    init(pin: String, name: String, language: String, timeCreated: Date?, timeModified: Date?, userCards: [UpdateUserCardDto]) {
        self.pin = pin
        self.name = name
        self.language = language
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.userCards = userCards
    }
}
