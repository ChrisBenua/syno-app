//
//  TranslationDto.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 20.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

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
