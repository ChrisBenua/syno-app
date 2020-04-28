import Foundation

class NewDictShare: Codable {
    let shareDictPin: String
    
    init(shareDictPin: String) {
        self.shareDictPin = shareDictPin
    }
}
