import Foundation

/// DTO for sending `getShare` request
class GetShareRequestConfig {
    /// Share id
    let shareUUID: String
    
    init(shareUUID: String) {
        self.shareUUID = shareUUID
    }
}

/// Class for configuring `getShare` request
class GetShareRequest: IRequest {
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.getShare(shareUUID: self.getShareRequestConfig.shareUUID)) {
                var request = URLRequest(url: url)
                request.method = .get
                request.setValue("Bearer " + userDefaultManager.getToken()!, forHTTPHeaderField: "Authorization")
                
                return request
            }
            
            return nil
        }
    }
    /// Service for fetching access token
    private var userDefaultManager: IUserDefaultsManager
    /// DTO to put inside request body
    private let getShareRequestConfig: GetShareRequestConfig
    
    init(manager: IUserDefaultsManager, getShareRequestConfig: GetShareRequestConfig) {
        userDefaultManager = manager
        self.getShareRequestConfig = getShareRequestConfig
    }
}
