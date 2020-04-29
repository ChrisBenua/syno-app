import Foundation

/// DTO for parsing fail/success server responses
class MessageResponseDto: Decodable {
    let message: String
}
