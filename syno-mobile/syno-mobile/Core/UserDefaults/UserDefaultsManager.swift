import Foundation

/// Service protocol for saving data to `UserDefaults`
protocol IUserDefaultsManager {
    func saveRegisterEmail(email: String)
    
    func getRegisterEmail() -> String?
    
    /// Saves user's auth token
    func saveToken(token: String)
    
    /// Saves user's email after login
    func saveEmail(email: String)
    
    /// Saves timestamp when token was received
    func saveTokenTimestamp(date: Date)

    /// clears token from `UserDefaults`
    func clearToken()

    /// Clears email from `UserDefaults`
    func clearEmail()
    
    /// Gets user's auth token
    func getToken() -> String?
    
    /// Gets user's email
    func getEmail() -> String?
    
    /// Sets current session network mode
    func setNetworkMode(isActive: Bool)
    
    /// Gets current session network mode
    func getNetworkMode() -> Bool
    
    /// Gets token timestamp
    func getTokenTimestamp() -> Int
}

class UserDefaultsManager: IUserDefaultsManager {
    /// Key for storing acces token
    private static let accessTokenKey: String = "accessTokenKey"
    /// Key for storing user's email
    private static let userEmailKey: String = "userEmailKey"
    /// Key for storing network mode
    private static let networkModeKey: String = "networkModeKey"
    /// Key for storing token timestamp
    private static let accessTokenTimestampKey: String = "accessTokenTimestampKey"
    
    private static let registerEmailKey: String = "registerEmailTokenKey"
  
    private static let versionCheckKey: String = "versionCheckKey"

    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsManager.accessTokenKey)
    }

    func saveEmail(email: String) {
        UserDefaults.standard.set(email, forKey: UserDefaultsManager.userEmailKey)
    }
    
    func saveTokenTimestamp(date: Date) {
        let timestamp: Int = Int(date.timeIntervalSince1970)
        UserDefaults.standard.set(timestamp, forKey: UserDefaultsManager.accessTokenTimestampKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.accessTokenKey)
    }

    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.userEmailKey)
    }
    
    func getTokenTimestamp() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsManager.accessTokenTimestampKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsManager.accessTokenKey)
    }

    func clearEmail() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsManager.userEmailKey)
    }
    
    func setNetworkMode(isActive: Bool) {
        UserDefaults.standard.set(isActive, forKey: UserDefaultsManager.networkModeKey)
    }
    
    func getNetworkMode() -> Bool {
        return (UserDefaults.standard.object(forKey: UserDefaultsManager.networkModeKey) as? Bool) ?? true
    }
    
    func saveRegisterEmail(email: String) {
        UserDefaults.standard.set(email, forKey: UserDefaultsManager.registerEmailKey)
    }
    
    func getRegisterEmail() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsManager.registerEmailKey)
    }
}
