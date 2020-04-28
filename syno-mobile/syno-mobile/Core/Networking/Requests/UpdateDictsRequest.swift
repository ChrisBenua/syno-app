import Foundation

class UpdateDictRequest: IRequest {
    private let updateRequestDto: UpdateRequestDto
    private var userDefaultManager: IUserDefaultsManager
    
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.UploadDicts) {
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
                    request.httpBody = try encoder.encode(updateRequestDto)
                } catch {
                    return nil
                }
                return request
            } else {
                return nil
            }
        }
    }
    
    init(updateRequestDto: UpdateRequestDto, userDefaultManager: IUserDefaultsManager) {
        self.updateRequestDto = updateRequestDto
        self.userDefaultManager = userDefaultManager
    }
}
