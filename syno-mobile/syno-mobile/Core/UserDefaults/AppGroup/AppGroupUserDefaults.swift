//
//  AppGroupUserDefaults.swift
//  syno-mobile
//
//  Created by Krisitan Benua on 23.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation

public enum AppGroup: String {
  case syno = "group.com.chrisbenua.synomobile"
}

class WidgetUserDefaults {
  struct CardData: Codable {
    var deeplink: String?
    let translatedWord: String
    let translations: [Translation]

    struct Translation: Codable {
      let translation: String
      let transcription: String?
    }
  }

  private static let userDefaults = UserDefaults.init(suiteName: AppGroup.syno.rawValue)!

  @UserDefaultsDataValue<CardData>(key: "cardData", userDefaults: WidgetUserDefaults.userDefaults)
  var cardData
}

@propertyWrapper
struct UserDefaultsDataValue<T: Codable> {
  let key: String
  let userDefaults: UserDefaults

  var wrappedValue: T? {
    get {
      guard let data = userDefaults.data(forKey: key) else { return nil }
      return try? JSONDecoder().decode(T.self, from: data)
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else { return }
      userDefaults.set(data, forKey: key)
    }
  }
}

private let placeholderCardData = WidgetUserDefaults.CardData(
  translatedWord: "Закат",
  translations: [
    WidgetUserDefaults.CardData.Translation(translation: "SundownSundown", transcription: "ˈsʌndaʊn"),
    WidgetUserDefaults.CardData.Translation(translation: "Sunset", transcription: "ˈsʌnset"),
    WidgetUserDefaults.CardData.Translation(translation: "Dusk", transcription: "dʌsk"),
    WidgetUserDefaults.CardData.Translation(translation: "Nightfall", transcription: "ˈnaɪtfɔːl")
  ]
)

