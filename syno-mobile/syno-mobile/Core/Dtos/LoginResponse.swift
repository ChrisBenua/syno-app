import Foundation

/// DTO for parsing login server response
struct LoginResponseDto: Decodable {
    /// Auth token
    let accessToken: String
    /// User's email
    let email: String
}
