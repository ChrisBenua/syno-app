import Foundation

class UpdateRequestDto: Codable {
    var existingDictPins: [String]
    
    var clientDicts: [UpdateUserDictionaryDto]
    
    init(existingDictPins: [String], clientDicts: [UpdateUserDictionaryDto]) {
        self.existingDictPins = existingDictPins
        self.clientDicts = clientDicts
    }
}

