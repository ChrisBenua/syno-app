import Foundation

/// Protocol for checking if user had logged in before
protocol IUserAuthHelper {
    /// Function for checking if user had logged in before and his token is valid
    func isAuthorized() -> Bool
}

class UserAuthHelper: IUserAuthHelper {
    private var userDefManager: IUserDefaultsManager
    
    func isAuthorized() -> Bool {
        let curr = Int(Date().timeIntervalSince1970)
        if ((userDefManager.getTokenTimestamp() == 0) || (curr - userDefManager.getTokenTimestamp() > 86300)) {
            return false
        }
        
        return true
    }
    /**
     Created new `UserAuthHelper`
     - Parameter userDefManager: instance responsilbe for storing and getting items from User Defaults
     */
    init(userDefManager: IUserDefaultsManager) {
        self.userDefManager = userDefManager
    }
}
