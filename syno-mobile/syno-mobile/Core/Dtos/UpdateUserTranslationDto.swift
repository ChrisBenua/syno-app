import Foundation

/// DTO for updating `DbTranslation` on server
class UpdateUserTranslationDto: Codable {
    let pin: String
    
    let translation: String
    
    let comment: String
    
    let transcription: String
    
    let usageSample: String
    
    let timeCreated: Date?
    
    let timeModified: Date?
    
    /**
     Creates new ``
     - Parameters:
        - pin: `DbTranslation` unique id
        - translation: actual translation
        - comment: user's comment
        - usageSample: user's provided sample
        - timeCreated: time when translation was created
        - timeModified: time when translation was modified
     */
    init(pin: String, translation: String, comment: String, transcription: String, usageSample: String, timeCreated: Date?, timeModified: Date?) {
        self.pin = pin
        self.translation = translation
        self.comment = comment
        self.transcription = transcription
        self.usageSample = usageSample
        self.timeCreated = timeCreated
        self.timeModified = timeModified
    }
}
