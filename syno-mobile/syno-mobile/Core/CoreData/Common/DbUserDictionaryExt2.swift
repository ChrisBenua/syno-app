//
//  DbUserDictionaryExt.swift
//  syno-mobile
//
//  Created by Krisitan Benua on 05.11.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import CoreData

extension DbUserDictionary {
  /// Gets `DbUserDictionary` cards array
  func getCards() -> [DbUserCard] {
      return (self.userCards?.allObjects ?? []) as! [DbUserCard]
  }

}
