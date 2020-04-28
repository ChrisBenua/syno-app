import Foundation

class UserTranslationDtoForLearnController {
    let translation: String?
    let transcription: String?
    let sample: String?
    let comment: String?
    
    init(translation: String?, transcription: String?, sample: String?, comment: String?) {
        self.translation = translation
        self.transcription = transcription
        self.sample = sample
        self.comment = comment
    }
    
    static func initFrom(translation: DbTranslation) -> UserTranslationDtoForLearnController {
        return UserTranslationDtoForLearnController(translation: translation.translation, transcription: translation.transcription, sample: translation.usageSample, comment: translation.comment)
    }
}
