import Foundation

class GetDictionaryResponseDto: Decodable {
    let id: Int64
    
    let name: String
    
    let timeCreated: Date
    
    let timeModified: Date
    
    let language: String?
    
    let userCards: [GetCardResponseDto]
    
    let pin: String
    
    init(id: Int64, name: String, timeCreated: Date, timeModified: Date, language: String?, userCards: [GetCardResponseDto], pin: String) {
        self.id = id
        self.name = name
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.userCards = userCards
        self.language = language
        self.pin = pin
    }

}

class GetCardResponseDto: Decodable {
    let id: Int64
    
    let translatedWord: String
        
    let timeCreated: Date
    
    let timeModified: Date
    
    let translations: [GetTranslationDto]
    
    let pin: String
    
    init(id: Int64, translatedWord: String, timeCreated: Date, timeModified: Date, translations: [GetTranslationDto], pin: String) {
        self.id = id
        self.translatedWord = translatedWord
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.translations = translations
        self.pin = pin
    }
}

class GetTranslationDto: Decodable {
    let id: Int64
    
    let translation: String
    
    let transcription: String
    
    let comment: String
    
    let usageSample: String
    
    let timeCreated: Date
    
    let timeModified: Date
    
    let pin: String
    
    init(id: Int64, translation: String, transcription: String, comment: String, usageSample: String, timeCreated: Date, timeModified: Date, pin: String) {
        self.id = id
        self.translation = translation
        self.transcription = transcription
        self.comment = comment
        self.usageSample = usageSample
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.pin = pin
    }
}
