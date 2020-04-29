import Foundation

/// Class for configuring `AllDicts` request
class AllDictsRequest: IRequest {
    var url: URLRequest? {
        get {
            if let url = URL(string: RequestSettings.AllDicts) {
                var request = URLRequest(url: url)
                request.method = .get
                request.setValue("Bearer " + userDefaultManager.getToken()!, forHTTPHeaderField: "Authorization")
                
                return request
            }
            
            return nil
        }
    }
    
    /// Service for fetching  access token
    private var userDefaultManager: IUserDefaultsManager
    
    init(manager: IUserDefaultsManager) {
        userDefaultManager = manager
    }
}
