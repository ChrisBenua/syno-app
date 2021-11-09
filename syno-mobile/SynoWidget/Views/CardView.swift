//
//  CardView.swift
//  syno-mobile
//
//  Created by Christian Benua on 20.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import SwiftUI
import Foundation

struct CardView: View {
  let cardData: WidgetUserDefaults.CardData
  let colors: CardViewColors
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Spacer(minLength: 0)
      TranslatedWordView(translatedWord: cardData.translatedWord, colors: colors)
      Spacer(minLength: 0)
      VStack(alignment: .leading, spacing: 4) {
        ForEach(cardData.translations.prefix(3), id: \.translation) {
          TranslationView(translation: $0, colors: colors)
        }
      }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
      Spacer(minLength: 0)
    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
  }
}

struct CardView2: View {
  let cardData: WidgetUserDefaults.CardData
  let colors: CardViewColors
  var displayedTranslations: [WidgetUserDefaults.CardData.Translation] {
    Array(cardData.translations.prefix(3))
  }
  
  var body: some View {
    GeometryReader { container in
      VStack(alignment: .center, spacing: 0) {
        Spacer(minLength: 5).frame(maxHeight: 7)
        TranslatedWordView2(translatedWord: cardData.translatedWord, colors: colors)
        Spacer(minLength: 0)
        VStack(alignment: .leading, spacing: 2) {
          ForEach(Array(displayedTranslations.enumerated()), id: \.element.translation) {
            TranslationView2(translation: $0.element, colors: colors)
            if $0.offset < displayedTranslations.count - 1 {
              HStack {
                Rectangle().stroke(lineWidth: 0).frame(height: 1).background(Color.gray.opacity(0.3)).padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 2))
              }
            }
          }
        }.padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
          .background(Color(colors.translationBackgroundColor).cornerRadius(16))
        
        Spacer(minLength: 13)
      }.frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
        .background(colors.backgroundView(container.size.width))
    }.embedInLink(url: cardData.deeplink.flatMap{ URL(string: $0) })
  }
}

struct TranslatedWordView: View {
  let translatedWord: String
  let colors: CardViewColors
  
  var body: some View {
    Text(translatedWord)
      .font(.system(.title2))
      .bold()
      .foregroundColor(Color(colors.headerColor))
      .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
  }
}

struct TranslatedWordView2: View {
  let translatedWord: String
  let colors: CardViewColors
  
  var body: some View {
    Text(translatedWord)
      .font(.system(.title2))
      .bold()
      .foregroundColor(Color(colors.headerColor))

  }
}

struct TranslationView: View {
  let translation: WidgetUserDefaults.CardData.Translation
  let colors: CardViewColors
  
  var body: some View {
    GeometryReader { container in
      HStack {
        VStack(alignment: .leading) {
          Text(translation.translation)
            .font(.system(.body))
            .foregroundColor(Color(colors.translationForegroundColor))
            .layoutPriority(1000)
          if let transcription = translation.transcription {
            Text(transcription)
              .font(.footnote)
              .foregroundColor(Color(colors.transcriptionForegroundColor))
          }
        }
        Spacer(minLength: 0)

      }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
  }
}

struct TranslationView2: View {
  let translation: WidgetUserDefaults.CardData.Translation
  let colors: CardViewColors

  var body: some View {
      HStack {
        HStack(alignment: .center) {
          Text(translation.translation)
            .font(.system(.body))
            .foregroundColor(Color(colors.translationForegroundColor))
            .layoutPriority(1000)
          if let transcription = translation.transcription {
            Text(transcription)
              .font(.footnote)
              .foregroundColor(Color(colors.transcriptionForegroundColor))
          }
          Spacer(minLength: 0)
        }
      }.frame(maxWidth: .infinity).padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
  }
}

private extension View {
  @ViewBuilder
  func embedInLink(url: URL?) -> some View {
    if let url = url {
      Link(destination: url) {
        self
      }
    } else {
      self
    }
  }
}
