//
//  DictionaryResponse.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 29.11.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

class GetDictionaryResponseDto: Decodable {
    let id: Int64
    
    let name: String
    
    let timeCreated: Date
    
    let timeModified: Date
    
    let language: String
    
    let userCards: [GetCardResponseDto]
    
    init(id: Int64, name: String, timeCreated: Date, timeModified: Date, language: String, userCards: [GetCardResponseDto]) {
        self.id = id
        self.name = name
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.userCards = userCards
        self.language = language
    }

}

class GetCardResponseDto: Decodable {
    let id: Int64
    
    let translatedWord: String
        
    let timeCreated: Date
    
    let timeModified: Date
    
    let translations: [GetTranslationDto]
    
    init(id: Int64, translatedWord: String, timeCreated: Date, timeModified: Date, translations: [GetTranslationDto]) {
        self.id = id
        self.translatedWord = translatedWord
        self.timeCreated = timeCreated
        self.timeModified = timeModified
        self.translations = translations
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
    
    init(id: Int64, translation: String, transcription: String, comment: String, usageSample: String, timeCreated: Date, timeModified: Date) {
        self.id = id
        self.translation = translation
        self.transcription = transcription
        self.comment = comment
        self.usageSample = usageSample
        self.timeCreated = timeCreated
        self.timeModified = timeModified
    }
    
    
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case translation
//        case comment
//        case usageSample = "usage_sample"
//        case timeCreated = "time_created"
//        case timeModified = "time_modified"
//    }
}
