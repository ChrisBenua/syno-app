import Foundation

/// DTO for receiving dictionaries from server
class GetDictionaryResponseDto: Decodable {
    /// Server's DB id
    let id: Int64
    
    let name: String
    
    let timeCreated: Date
    
    let timeModified: Date
    
    let language: String?
    
    let userCards: [GetCardResponseDto]
    
    let pin: String
    
    /**
     Creates new `GetDictionaryResponseDto`
     - Parameter id: Server's DB id
     - Parameter name: dictionary name
     - Parameter timeCreated: time when dictionary was created
     - Parameter timeModified: time when dictionary was modified
     - Parameter language: language of dictionary
     - Parameter userCards: Dictionary cards
     - Parameter pin: Unique id
     */
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

/// DTO for receiving cards from server
class GetCardResponseDto: Decodable {
    let id: Int64
    
    let translatedWord: String
        
    let timeCreated: Date
    
    let timeModified: Date
    
    let translations: [GetTranslationDto]
    
    let pin: String
    
    /**
     Creates new ``
     - Parameter id: Server's DB id
     - Parameter timeCreated: time when card was created
     - Parameter timeModified: time when card was modified
     - Parameter translations: list of card's translations
     - Parameter pin: Unique id
     */
    init(id: Int64, translatedWord: String, timeCreated: Date, timeModified: Date, translations: [GetTranslationDto], pin: String) {
        self.id = id
        self.translatedWord = translatedWord
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.translations = translations
        self.pin = pin
    }
}

/// DTO for receiving translations from server
class GetTranslationDto: Decodable {
    let id: Int64
    
    let translation: String
    
    let transcription: String
    
    let comment: String
    
    let usageSample: String
    
    let timeCreated: Date
    
    let timeModified: Date
    
    let pin: String
    
    /**
     Creates new `GetTranslationDto`
     - Parameter id: Server's db id
     - Parameter transcription: `translation`'s transcription
     - Parameter comment: user's comment
     - Parameter usageSample: user's usage sample for `translation`
     - Parameter timeCreated: time when translation was created
     - Parameter timeModified: time when translation was modified
     - Parameter pin: unique id
     */
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
