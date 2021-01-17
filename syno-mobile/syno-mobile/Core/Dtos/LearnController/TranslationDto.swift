import Foundation
import CoreData

/// DTO class for passing `DbTranslation` copy to `LearnViewController`
class UserTranslationDtoForLearnController {
    let translation: String?
    let transcription: String?
    let sample: String?
    let comment: String?
    
    /**
     Creates new `UserTranslationDtoForLearnController`
     */
    init(translation: String?, transcription: String?, sample: String?, comment: String?) {
        self.translation = translation
        self.transcription = transcription
        self.sample = sample
        self.comment = comment
    }
    
    /**
     Creates `UserTranslationDtoForLearnController` from given `DbTranslation`
     */
    static func initFrom(translation: DbTranslation) -> UserTranslationDtoForLearnController {
        return UserTranslationDtoForLearnController(translation: translation.translation, transcription: translation.transcription, sample: translation.usageSample, comment: translation.comment)
    }
}
