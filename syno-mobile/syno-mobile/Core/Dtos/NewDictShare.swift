import Foundation

/// DTO for sending request to create new share
class NewDictShare: Codable {
    /// Unique `DbUserDictionary` id to share
    let shareDictPin: String
    
    /**
     Creates new `NewDictShare`
     - Parameter shareDictPin:Unique `DbUserDictionary` id to share
     */
    init(shareDictPin: String) {
        self.shareDictPin = shareDictPin
    }
}
