import Foundation

class UpdateUserDictionaryDto: Codable {
    let pin: String
    
    let name: String
    
    let language: String
    
    let timeCreated: Date?
    
    let timeModified: Date?
    
    let userCards: [UpdateUserCardDto]
    
    init(pin: String, name: String, language: String, timeCreated: Date?, timeModified: Date?, userCards: [UpdateUserCardDto]) {
        self.pin = pin
        self.name = name
        self.language = language
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.userCards = userCards
    }
}
