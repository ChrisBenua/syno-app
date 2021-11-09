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
    let colors: SynoWidgetTheme

    var body: some View {
      CardView2(cardData: entry.cardData, colors: colors.cardsColors)
    }
}

enum SynoWidgetTheme: String {
  case light
  case dark
}

struct SynoWidget: Widget {
    var kind: String {
      "SynoWidget" + colors.rawValue
    }
    var colors: SynoWidgetTheme = .light

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: SynoCardDataTimelineProvider()) { entry in
          SynoWidgetEntryView(entry: entry, colors: colors).unredacted()
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Виджет с Вашими карточками")
        .description("Обновляется каждый день в 6 часов утра")
    }
}

@main
struct SynoWidgetsBundle: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    SynoWidget(colors: .light)
    SynoWidget(colors: .dark)
  }
}

struct SynoWidget_Previews: PreviewProvider {
    static var previews: some View {
      SynoWidgetEntryView(entry: SynoCardDataEntry(date: Date(), cardData: placeholderCardData), colors: .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

private extension SynoWidgetTheme {
  var cardsColors: CardViewColors {
    switch self {
    case .light:
      return .light
    case .dark:
      return .dark
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
