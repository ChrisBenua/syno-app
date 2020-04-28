import Foundation

class GetShareRequestConfig {
    let shareUUID: String
    
    init(shareUUID: String) {
        self.shareUUID = shareUUID
    }
}

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
    
    private var userDefaultManager: IUserDefaultsManager
    private let getShareRequestConfig: GetShareRequestConfig
    
    init(manager: IUserDefaultsManager, getShareRequestConfig: GetShareRequestConfig) {
        userDefaultManager = manager
        self.getShareRequestConfig = getShareRequestConfig
    }
}
