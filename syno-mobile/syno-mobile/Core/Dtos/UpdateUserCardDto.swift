import Foundation


class UpdateUserCardDto: Codable {
    let pin: String
    
    let translatedWord: String
    
    let timeCreated: Date?
    
    let timeModified: Date?
    
    let translations: [UpdateUserTranslationDto]
    
    init(pin: String, translatedWord: String, timeCreated: Date?, timeModified: Date?, translations: [UpdateUserTranslationDto]) {
        self.pin = pin
        self.translatedWord = translatedWord
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.translations = translations
    }
}
