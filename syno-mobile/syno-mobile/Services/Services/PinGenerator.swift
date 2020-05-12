import Foundation

/// Class for generating IDs for DbUserDictionary, DbUserCard, DbTranslation
class PinGenerator {
    /// Generates unique identifier
    public static func generatePin() -> String {
        return UUID().uuidString
    }
}
