//
//  UpdateWidgetDataTask.swift
//  syno-mobile
//
//  Created by Krisitan Benua on 23.10.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import BackgroundTasks
import CoreData
import WidgetKit


protocol UpdateWidgetDataTaskPerforming {
  func updateWidgetDataOnFirstFetch()
  func registerUpdateWidgetDataTask()
  func scheduleUpdateWidgetData()
}


class UpdateWidgetDataTask: UpdateWidgetDataTaskPerforming {
  private let storageManager: IStorageCoordinator
  private let widgetUserDefaults: WidgetUserDefaults
  private let userDefaults = UpdateWidgetDataTaskUserDefaults()

  init(storageManager: IStorageCoordinator, widgetUserDefaults: WidgetUserDefaults) {
    self.storageManager = storageManager
    self.widgetUserDefaults = widgetUserDefaults
  }
  private func updateWidgetData(task: BGTask) {
    if #available(iOS 14.0, *) {
      scheduleUpdateWidgetData()
      let operation = UpdateWidgetDataOperation(storageManager: storageManager, widgetUserDefaults: widgetUserDefaults)

      task.expirationHandler = {
        operation.cancel()
      }

      operation.completionBlock = {
        task.setTaskCompleted(success: !operation.isCancelled)
      }
      OperationQueue().addOperation(operation)
    }
  }

  func updateWidgetDataOnFirstFetch() {
    if #available(iOS 14.0, *) {
      let operation = UpdateWidgetDataOperation(storageManager: storageManager, widgetUserDefaults: widgetUserDefaults)
      OperationQueue().addOperation(operation)
    }
  }

  func scheduleUpdateWidgetData() {
    let nextMorning = nextMorning()
    if userDefaults.lastScheduledDate == nextMorning { return }
    let request = BGAppRefreshTaskRequest(identifier: "com.chrisbenua.synomobile.updateWidgetData")
    request.earliestBeginDate = nextMorning

   do {
     try BGTaskScheduler.shared.submit(request)
     userDefaults.lastScheduledDate = nextMorning
   } catch {
     print("Could not schedule app refresh: \(error)")
   }
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

  func registerUpdateWidgetDataTask() {
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: "com.chrisbenua.synomobile.updateWidgetData",
      using: nil) { task in
        self.updateWidgetData(task: task)
      }
  }
}

private class UpdateWidgetDataTaskUserDefaults {
  @UserDefaultsDataValue<String>(key: "UpdateWidgetDataTask.lastScheduledDate", userDefaults: .standard)
  private var lastScheduledDateString

  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter.timeZone = TimeZone.current
    return formatter
  }()

  var lastScheduledDate: Date? {
    get {
      lastScheduledDateString.flatMap(dateFormatter.date(from:))
    }
    set {
      if let newValue = newValue {
        lastScheduledDateString = dateFormatter.string(from: newValue)
      } else {
        lastScheduledDateString = nil
      }
    }
  }
}

@available(iOS 14.0, *)
private class UpdateWidgetDataOperation: Operation {
  private let storageManager: IStorageCoordinator
  private let widgetUserDefaults: WidgetUserDefaults

  init(storageManager: IStorageCoordinator, widgetUserDefaults: WidgetUserDefaults) {
    self.storageManager = storageManager
    self.widgetUserDefaults = widgetUserDefaults
  }

  override func main() {
    let context = storageManager.stack.mainContext
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

      widgetUserDefaults.cardData = WidgetUserDefaults.CardData(
        deeplink: deeplink?.absoluteString,
        translatedWord: card.translatedWord ?? "",
        translations: card.getTranslations().map({ translation in
            .init(translation: translation.translation ?? "", transcription: translation.transcription)
        })
      )
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
