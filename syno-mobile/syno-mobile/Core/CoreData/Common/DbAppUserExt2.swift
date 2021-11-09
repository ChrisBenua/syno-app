import Foundation
import CoreData

extension DbAppUser {
  /// Creates `NSFetchRequest` for fetching active user
  static func requestActive() -> NSFetchRequest<DbAppUser> {
      let request: NSFetchRequest<DbAppUser> = DbAppUser.fetchRequest()
      request.predicate = NSPredicate(format: "isCurrent == YES")

      return request
  }


  func getDictionaries(includeDeletedManually: Bool = false) -> [DbUserDictionary] {
      var dicts: [DbUserDictionary] = self.dictionaries?.toArray() ?? []
      if !includeDeletedManually {
          dicts = dicts.filter{ !$0.wasDeletedManually }
      }
      return dicts
  }
}
