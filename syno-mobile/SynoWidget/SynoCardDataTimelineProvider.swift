//
//  SynoCardDataProvider.swift
//  syno-mobile
//
//  Created by Christian Benua on 20.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Intents
import WidgetKit
import CoreData

struct SynoCardDataEntry: TimelineEntry {
  var date: Date
  var cardData: WidgetUserDefaults.CardData
}

struct SynoCardDataTimelineProvider: IntentTimelineProvider {
  private let widgetUserDefaults = WidgetUserDefaults()
  private let coreDataStack: CoreDataStack = CoreDataStack()

  func placeholder(in context: Context) -> SynoCardDataEntry {
    SynoCardDataEntry(date: Date(), cardData: placeholderCardData)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SynoCardDataEntry) -> ()) {
    let entry = SynoCardDataEntry(date: Date(), cardData: getNewModel() ?? placeholderCardData)
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SynoCardDataEntry>) -> ()) {    
    let timeline = Timeline(entries: [SynoCardDataEntry(date: Date(), cardData: getNewModel() ?? placeholderCardData)], policy: .after(nextMorning()))
    completion(timeline)
  }

  private func nextMorning() -> Date {
    let calendar = Calendar.current
    if calendar.component(.hour, from: Date()) < 6 {
      return calendar.date(byAdding: .hour, value: 6, to: calendar.startOfDay(for: Date()))!
    } else {
      let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
      let tomorrowMorning = calendar.date(byAdding: .hour, value: 6, to: calendar.startOfDay(for: tomorrow))!
      return tomorrowMorning
    }
  }

  private func getNewModel() -> WidgetUserDefaults.CardData? {
    let context = coreDataStack.mainContext
    var returnValue: WidgetUserDefaults.CardData? = nil
    context.performAndWait {
      guard let appUser = try? context.fetch(DbAppUser.requestActive()).first else { return }

      let cards = appUser.getDictionaries().flatMap{ $0.getCards() }
      let card: DbUserCard?
      if cards.contains(where: { $0.getTranslations().count > 1 }) {
        card = cards.filter{ $0.getTranslations().count > 1 }.randomElement()
      } else {
        card = cards.randomElement()
      }
      guard let card = card else { return }
      var deeplink: URL? = nil
      if let dictId = card.sourceDictionary?.pin, let cardId = card.pin {
          var comps = URLComponents()
          comps.scheme = "https"
          comps.host = "chrisbenua.site"
          comps.path = "/widgetOpenCard"
          comps.queryItems = [URLQueryItem(name: "dictId", value: dictId), URLQueryItem(name: "cardId", value: cardId)]
          deeplink = comps.url
      }

      returnValue = WidgetUserDefaults.CardData(
        deeplink: deeplink?.absoluteString,
        translatedWord: card.translatedWord ?? "",
        translations: card.getTranslations().map({ translation in
            .init(translation: translation.translation ?? "", transcription: translation.transcription)
        })
      )
    }
    return returnValue
  }
}

private let placeholderCardData = WidgetUserDefaults.CardData(
  translatedWord: "Закат",
  translations: [
    WidgetUserDefaults.CardData.Translation(translation: "Sundown", transcription: "ˈsʌndaʊn"),
    WidgetUserDefaults.CardData.Translation(translation: "Sunset", transcription: "ˈsʌnset"),
    WidgetUserDefaults.CardData.Translation(translation: "Dusk", transcription: "dʌsk"),
    WidgetUserDefaults.CardData.Translation(translation: "Nightfall", transcription: "ˈnaɪtfɔːl"),
  ]
)

