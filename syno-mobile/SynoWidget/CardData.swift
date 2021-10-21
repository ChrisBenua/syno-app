//
//  CardData.swift
//  syno-mobile
//
//  Created by Christian Benua on 20.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

struct CardData {
  let translatedWord: String
  let translations: [Translation]
  
  struct Translation {
    let translation: String
    let transcription: String?
  }
}
