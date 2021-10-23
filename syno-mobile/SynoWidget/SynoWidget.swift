//
//  SynoWidget.swift
//  SynoWidget
//
//  Created by Christian Benua on 20.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct SynoWidgetEntryView : View {
    var entry: SynoCardDataTimelineProvider.Entry

    var body: some View {
      CardView2(cardData: entry.cardData)
    }
}

@main
struct SynoWidget: Widget {
    let kind: String = "SynoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: SynoCardDataTimelineProvider()) { entry in
          SynoWidgetEntryView(entry: entry).unredacted()
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Виджет с Вашими карточками")
        .description("Обновляется каждый день в 6 часов утра")
    }
}

struct SynoWidget_Previews: PreviewProvider {
    static var previews: some View {
        SynoWidgetEntryView(entry: SynoCardDataEntry(date: Date(), cardData: placeholderCardData))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
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
