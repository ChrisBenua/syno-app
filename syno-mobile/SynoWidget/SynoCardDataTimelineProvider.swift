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
  var cardData: CardData
}

struct SynoCardDataTimelineProvider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SynoCardDataEntry {
    SynoCardDataEntry(date: Date(), cardData: placeholderCardData)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SynoCardDataEntry) -> ()) {
    let entry = SynoCardDataEntry(date: Date(), cardData: placeholderCardData)
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SynoCardDataEntry>) -> ()) {
    //var entries: [SynoCardDataEntry] = []
    
    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//    let currentDate = Date()
//    for hourOffset in 0 ..< 5 {
//      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//      let entry = SimpleEntry(date: entryDate, configuration: configuration)
//      entries.append(entry)
//    }
    let entry = placeholderCardData
    
    let timeline = Timeline(entries: [SynoCardDataEntry(date: Date(), cardData: entry)], policy: .atEnd)
    completion(timeline)
  }
}

private let placeholderCardData = CardData(
  translatedWord: "Закат",
  translations: [
    CardData.Translation(translation: "Sundown", transcription: "ˈsʌndaʊn"),
    CardData.Translation(translation: "Sunset", transcription: "ˈsʌnset"),
    CardData.Translation(translation: "Dusk", transcription: "dʌsk"),
    CardData.Translation(translation: "Nightfall", transcription: "ˈnaɪtfɔːl"),
  ]
)

