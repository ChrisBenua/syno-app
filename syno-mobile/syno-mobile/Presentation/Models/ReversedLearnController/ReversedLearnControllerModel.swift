import Foundation

struct ReversedLearnControllerTranslationDto {
  let translation: String?
  let transcription: String?
  let sample: String?
  let comment: String?
}

struct ReversedLearnControllerCardDto {
  let translatedWord: String?
  let translations: [ReversedLearnControllerTranslationDto]
}

struct ReversedLearnControllerCompactCardDto {
  let translatedWord: String?
  let translations: [String?]
}

struct ReversedLearnControllerDictionaryDto {
  let name: String
  let cards: [ReversedLearnControllerCardDto]
}

protocol IReversedLearnControllerModel {
  func getCard(at position: Int) -> ReversedLearnControllerCardDto
  func getDictionaryName() -> String
  func getCardsCount() -> Int
}

class ReversedLearnControllerModelImpl: IReversedLearnControllerModel {
  private var dictDto: ReversedLearnControllerDictionaryDto
  
  func getCard(at position: Int) -> ReversedLearnControllerCardDto {
    return dictDto.cards[position]
  }
  
  func getDictionaryName() -> String {
    return dictDto.name
  }
  
  func getCardsCount() -> Int {
    return dictDto.cards.count
  }
  
  init(dict: DbUserDictionary) {
    self.dictDto = ReversedLearnControllerDictionaryDto(
      name: dict.name ?? "",
      cards: dict.getCards().map {
        return ReversedLearnControllerCardDto(
          translatedWord: $0.translatedWord,
          translations: $0.getTranslations().map { translation in
            ReversedLearnControllerTranslationDto(
              translation: translation.translation,
              transcription: translation.transcription,
              sample: translation.usageSample,
              comment: translation.comment
            )
          }
        )
      }
    )
  }
}

