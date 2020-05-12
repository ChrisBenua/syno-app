import Foundation

/// Class for configuring `AddShare` request
class AddShareRequest: IRequest {
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.AddShare) {
                var request = URLRequest(url: url)
                request.method = .post
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.setValue("Bearer " + userDefaultManager.getToken()!, forHTTPHeaderField: "Authorization")
                request.timeoutInterval = TimeInterval(exactly: 2000)!
                do {
                    let encoder = JSONEncoder()
                    encoder.keyEncodingStrategy = .convertToSnakeCase
                    encoder.dateEncodingStrategy = .formatted(.iso8601Full)
                    request.httpBody = try encoder.encode(newDictShareDto)
                } catch {
                    return nil
                }
                return request
            } else {
                return nil
            }
        }
    }
    
    /// Service for fetching user's access token
    private var userDefaultManager: IUserDefaultsManager
    /// DTO to put inside request body
    private var newDictShareDto: NewDictShare
    
    init(dto: NewDictShare, userDefManager: IUserDefaultsManager) {
        self.newDictShareDto = dto
        self.userDefaultManager = userDefManager
    }
}
