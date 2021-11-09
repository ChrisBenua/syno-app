import Foundation
import CoreData

extension DbUserCard {
    /// Gets `DbUserCard` translations array
    func getTranslations() -> [DbTranslation] {
        return (self.translations?.array ?? []) as! [DbTranslation]
    }
}
