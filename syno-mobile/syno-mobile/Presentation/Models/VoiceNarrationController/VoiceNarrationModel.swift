//
//  VoiceNarrationModel.swift
//  syno-mobile
//
//  Created by Christian Benua on 24.01.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import AVFoundation


protocol ISingleVoiceNarrationService: AVSpeechSynthesizerDelegate {
    var delegate: IVoiceNarrationServiceDelegate? { get set }
    
    func getCurrCardUtterances() -> [AVSpeechUtterance]?
    func getCurrCardNumber() -> Int
    func getAmountOfCards() -> Int
    func getDictName() -> String
    
    func refresh()
}

protocol IVoiceNarrationServiceDelegate: AnyObject {
    func onCompletedCurrCard()
    func onCancelled()
}

protocol IVoiceNarrationService {
    func hasNext() -> Bool
    func hasPrev() -> Bool
    func position() -> Int
    
    func goNext()
    func goPrev()
    
    var singleNarrationServices: [ISingleVoiceNarrationService] { get }
    var currSingleVoiceNarrationService: ISingleVoiceNarrationService { get }
}

class SingleVoiceNarrationServiceImpl: NSObject, ISingleVoiceNarrationService {
    private var dict: DbUserDictionary
    private var cards: [DbUserCard]
    private var currCardPos: Int = 0
    private var currCard: DbUserCard {
        return cards[currCardPos]
    }
    private var lastDoneUtterance: AVSpeechUtterance?
    
    weak var delegate: IVoiceNarrationServiceDelegate?
    
    func getCurrCardNumber() -> Int {
        return currCardPos
    }
    
    func getAmountOfCards() -> Int {
        return cards.count
    }
    
    func getDictName() -> String {
        return self.dict.name ?? ""
    }
    
    private func getLanguages() -> (String, String) {
        if let language = self.dict.language?.lowercased() {
            let split = language.split(separator: "-")
            if split.count > 1 {
                return (ToLocale.getLocale(str: String(split[0])), ToLocale.getLocale(str: String(split[1])))
            }
        }
        return (ToLocale.getLocale(str: ""), ToLocale.getLocale(str: ""))
    }
    
    private func getRealCardUtterances() -> [AVSpeechUtterance]? {
        var dictNameUtterances: [AVSpeechUtterance] = []
        let languages = getLanguages()
        if currCardPos == 0 {
            let utterance = AVSpeechUtterance(string: "Словарь")
            utterance.voice = AVSpeechSynthesisVoice(language: ToLocale.getLocale(str: "ru"))
            let dictName = getDictName()
            let dictNameUtterance = AVSpeechUtterance(string: dictName)
            let character: Character = Character(dictName[dictName.startIndex].lowercased())
            let isRussianDictName: Bool = (Character("а") <= character) &&  (character  <= Character("я"))
            dictNameUtterance.voice = AVSpeechSynthesisVoice(language: ToLocale.getLocale(str: isRussianDictName ? "ru" : "en"))
            dictNameUtterances = [utterance, dictNameUtterance]
            dictNameUtterance.postUtteranceDelay = 0.2
        }
        if currCardPos < cards.count {
            let translatedWordUtterance = AVSpeechUtterance(string: currCard.translatedWord ?? "")
            translatedWordUtterance.voice = AVSpeechSynthesisVoice(language: languages.0)
            translatedWordUtterance.postUtteranceDelay = 0.7
            if currCardPos == 0 {
                translatedWordUtterance.preUtteranceDelay = 0.5
            }
            
            let translationsUtterances = currCard.getTranslations().reversed().map { (trans) -> AVSpeechUtterance in
                let utterance = AVSpeechUtterance(string: trans.translation ?? "")
                utterance.voice = AVSpeechSynthesisVoice(language: languages.1)
                utterance.preUtteranceDelay = 0.5
                
                return utterance
            }
            let result = dictNameUtterances + [translatedWordUtterance] + translationsUtterances
            result.last?.postUtteranceDelay = 0.7
            return result
        }
        return nil
    }
    
    func getCurrCardUtterances() -> [AVSpeechUtterance]? {
        return getRealCardUtterances()
    }
    
    func refresh() {
        self.currCardPos = 0
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.lastDoneUtterance = utterance
        if let ut = self.getRealCardUtterances()?.last {
            if utterance.speechString == ut.speechString {
                self.currCardPos += 1
                self.delegate?.onCompletedCurrCard()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.delegate?.onCancelled()
    }
    
    init(dict: DbUserDictionary) {
        self.dict = dict
        self.cards = dict.getCards().shuffled()
    }
}

class IVoiceNarrationServiceImpl: IVoiceNarrationService {
    
    var singleNarrationServices: [ISingleVoiceNarrationService] {
        get {
            cardNarrationServices
        }
    }
    
    private var currDictPos: Int
    private var cardNarrationServices: [ISingleVoiceNarrationService]
    
    
    func hasNext() -> Bool {
        currDictPos + 1 < cardNarrationServices.count
    }
    
    func hasPrev() -> Bool {
        currDictPos > 0
    }
    
    func position() -> Int {
        currDictPos
    }
    
    func goNext() {
        currDictPos += 1
    }
    
    func goPrev() {
        currDictPos -= 1
    }
    
    var currSingleVoiceNarrationService: ISingleVoiceNarrationService {
        get {
            return cardNarrationServices[currDictPos]
        }
    }
    
    init(storageManager: IStorageCoordinator, dict: DbUserDictionary) {
        let dicts: [DbUserDictionary] = try! storageManager.stack.mainContext.fetch(DbUserDictionary.requestSortedByName(owner: storageManager.getCurrentAppUser()!))
        self.currDictPos = dicts.firstIndex(where: { $0.objectID == dict.objectID })!
        self.cardNarrationServices = dicts.map({ (dict) -> ISingleVoiceNarrationService in
            return SingleVoiceNarrationServiceImpl(dict: dict)
        })
    }
}
