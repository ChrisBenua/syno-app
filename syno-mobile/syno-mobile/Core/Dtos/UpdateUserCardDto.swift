import Foundation

/// DTO for updating `DbUserCard` on server
class UpdateUserCardDto: Codable {
    let pin: String
    
    let translatedWord: String
    
    let timeCreated: Date?
    
    let timeModified: Date?
    
    let translations: [UpdateUserTranslationDto]
    
    /**
      Creates new `UpdateUserCardDto`
     - Parameters:
        - pin: `DbUserCard` unique id
        - translatedWord:  Card's translated word
        - timeCreated: time when card was created
        - timeModified: time when card was modified
        - translations: list of card's translations
     */
    init(pin: String, translatedWord: String, timeCreated: Date?, timeModified: Date?, translations: [UpdateUserTranslationDto]) {
        self.pin = pin
        self.translatedWord = translatedWord
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.translations = translations
    }
}
