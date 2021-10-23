//
//  SynoCardDataProvider.swift
//  syno-mobile
//
//  Created by Christian Benua on 20.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Intents
import WidgetKit

struct SynoCardDataEntry: TimelineEntry {
  var date: Date
  var cardData: WidgetUserDefaults.CardData
}

struct SynoCardDataTimelineProvider: IntentTimelineProvider {
  private let widgetUserDefaults = WidgetUserDefaults()

  func placeholder(in context: Context) -> SynoCardDataEntry {
    SynoCardDataEntry(date: Date(), cardData: placeholderCardData)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SynoCardDataEntry) -> ()) {
    let entry = SynoCardDataEntry(date: Date(), cardData: widgetUserDefaults.cardData ?? placeholderCardData)
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SynoCardDataEntry>) -> ()) {    
    let timeline = Timeline(entries: [SynoCardDataEntry(date: Date(), cardData: widgetUserDefaults.cardData ?? placeholderCardData)], policy: .never)
    completion(timeline)
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

