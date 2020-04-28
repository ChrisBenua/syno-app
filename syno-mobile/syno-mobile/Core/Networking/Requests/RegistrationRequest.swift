import Foundation

struct RegisterDto: Encodable {
    let email: String
    let password: String
}


class RegisterRequest: IRequest {
    private let registerDto: RegisterDto
    
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.RegisterEndPoint) {
                var request = URLRequest(url: url)
                request.method = .post
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.timeoutInterval = TimeInterval(exactly: 2000)!
                do {
                    request.httpBody = try JSONEncoder().encode(registerDto)
                } catch {
                    return nil
                }
                return request
            } else {
                return nil
            }
        }
    }
    
    init(registerDto: RegisterDto) {
        self.registerDto = registerDto
    }
    
}
