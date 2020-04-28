import Foundation

struct LoginResponseDto: Decodable {
    let accessToken: String
    let email: String
}
