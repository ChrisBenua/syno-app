import Foundation

/// DTO for sending login request
struct LoginDto: Encodable {
    /// User's email
    let email: String
    /// User's password
    let password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// Class for configuring Login backend request
class LoginRequest: IRequest {
    typealias Model = LoginRequest

    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.LoginEndPoint) {
                var request = URLRequest(url: url)
                request.method = .post
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.timeoutInterval = TimeInterval(exactly: 2000)!
                do {
                    request.httpBody = try JSONEncoder().encode(loginDto)
                } catch {
                    return nil
                }
                return request
            } else {
                return nil
            }
        }
    }
    /// Login credentials to put inside request body
    let loginDto: LoginDto

    init(loginDto: LoginDto) {
        self.loginDto = loginDto
    }
}
