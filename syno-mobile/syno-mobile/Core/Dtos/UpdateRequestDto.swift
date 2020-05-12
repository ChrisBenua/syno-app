import Foundation

/// DTO for sending request for creating copy on server
class UpdateRequestDto: Codable {
    /// List of dict pins on client
    var existingDictPins: [String]
    
    /**
     List of client dictionaries
     
     May not contain all dictionaries for pagination
     */
    var clientDicts: [UpdateUserDictionaryDto]
    
    /**
     Creates new `UpdateRequestDto`
     */
    init(existingDictPins: [String], clientDicts: [UpdateUserDictionaryDto]) {
        self.existingDictPins = existingDictPins
        self.clientDicts = clientDicts
    }
}

