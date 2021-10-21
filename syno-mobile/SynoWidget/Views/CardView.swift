//
//  CardView.swift
//  syno-mobile
//
//  Created by Christian Benua on 20.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import SwiftUI

struct CardView: View {
  let cardData: CardData
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Spacer(minLength: 0)
      TranslatedWordView(translatedWord: cardData.translatedWord)
      Spacer(minLength: 0)
      VStack(alignment: .leading, spacing: 4) {
        ForEach(cardData.translations.prefix(3), id: \.translation) {
          TranslationView(translation: $0)
        }
      }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
      //.background(color.cornerRadius(10))
      Spacer(minLength: 0)
    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
  }
}

struct CardView2: View {
  let cardData: CardData
  var displayedTranslations: [CardData.Translation] {
    Array(cardData.translations.prefix(3))
  }
  
  var body: some View {
    GeometryReader { container in
      VStack(alignment: .center, spacing: 0) {
        Spacer(minLength: 5).frame(maxHeight: 7)
        TranslatedWordView2(translatedWord: cardData.translatedWord)
        Spacer(minLength: 0)
        VStack(alignment: .leading, spacing: 2) {
          //List {
          ForEach(Array(displayedTranslations.enumerated()), id: \.element.translation) {
            TranslationView2(translation: $0.element, index: $0.offset)
            if $0.offset < displayedTranslations.count - 1 {
              HStack {
                Rectangle().stroke(lineWidth: 0).frame(maxHeight: 1).background(Color.gray.opacity(0.3)).padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 2))
              }
            }
          }
          //}
        }.padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
        .background(color.cornerRadius(16))
        //
        
        Spacer(minLength: 13)
      }.frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        .background(RadialGradient(colors: [greenColor, endColor], center: UnitPoint(x: 0.5, y: 0), startRadius: 20, endRadius: container.size.height))
    }

  }
}

struct TranslatedWordView: View {
  let translatedWord: String
  
  var body: some View {
    Text(translatedWord)
      .font(.system(.title2))
      .bold()
      .foregroundColor(Color(.headerMainColor))
      .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
      //.background(color.cornerRadius(10))
  }
}

struct TranslatedWordView2: View {
  let translatedWord: String
  
  var body: some View {
    Text(translatedWord)
      .font(.system(.title2))
      .bold()
      .foregroundColor(Color(.headerMainColor))
      //.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
      //.background(color.cornerRadius(6))
  }
}

struct TranslationView: View {
  let translation: CardData.Translation
  
  var body: some View {
    GeometryReader { container in
      HStack {
        VStack(alignment: .leading) {
          Text(translation.translation)
            .font(.system(.body)).layoutPriority(1000)
          if let transcription = translation.transcription {
            Text(transcription)
              .font(.footnote)
              .foregroundColor(Color(UIColor.secondaryLabel))
          }
        }
        Spacer(minLength: 0)

      }.padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
      //.frame(maxWidth: container.size.width, alignment: .leading)
        .background(color.cornerRadius(10))
    }
  }
}

struct TranslationView2: View {
  let translation: CardData.Translation
  let index: Int
  
  var body: some View {
      HStack {
        HStack(alignment: .center) {
          //Spacer(minLength: 0)
          Text(translation.translation)
            .font(.system(.body)).layoutPriority(1000)
          if let transcription = translation.transcription {
            Text(transcription)
              .font(.footnote)
              .foregroundColor(Color(UIColor.secondaryLabel))
          }
          Spacer(minLength: 0)
        }
      }.frame(maxWidth: .infinity).padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
      //.frame(maxWidth: container.size.width, alignment: .leading)
      //  .background(backgroundColor.cornerRadius(3))
  }
}

private let color = Color(red: 241.0 / 255, green: 241.0 / 255, blue: 241.0 / 255)
private let backgroundColor = Color(red: 137.0 / 255, green: 190.0 / 255, blue: 113.0 / 255, opacity: 0.1)
private let greenColor = Color(red: 137.0 / 255, green: 190.0 / 255, blue: 113.0 / 255, opacity: 0.1)
private let endColor = Color(red: 137.0 / 255, green: 190.0 / 255, blue: 113.0 / 255, opacity: 0.05)
