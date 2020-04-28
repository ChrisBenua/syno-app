import Foundation

/// protocol defining Login inner logic
protocol ILoginService {
    /**
     Asynchronically logins given user
     - Parameter loginDto: user credentials
     - Parameter completionHandler: completion callback
     */
    func login(loginDto: LoginDto, completionHandler: @escaping (Result<String>) -> Void)
    
    /**
     Sets network mode
     */
    func setNetworkMode(isActive: Bool)
    
    /// Creates guest user if needed, or uses previous logged in user
    func createGuestUser() -> Bool
    
    /// Gets current user email
    func currentUserEmail() -> String
}

/// Class for handling Login
class LoginService: ILoginService {
    private var requestSender: IRequestSender
    private var userDefaultsManager: IUserDefaultsManager
    private var storageManager: IAppUserStorageManager
    
    /**
     Create new `LoginService`
     - Parameter storageManager: instance for saving/getting AppUsers
     - Parameter requestSender: instance for sending requests to backend
     - Parameter userDefaultsManager: instance for saving data to user Defaults
     */
    init(storageManager: IAppUserStorageManager, requestSender: IRequestSender, userDefaultsManager: IUserDefaultsManager) {
        self.storageManager = storageManager
        self.requestSender = requestSender
        self.userDefaultsManager = userDefaultsManager
    }
    
    func currentUserEmail() -> String {
        return self.storageManager.getCurrentUserEmail() ?? "Guest"
    }
    
    func createGuestUser() -> Bool {
        if (self.storageManager.getCurrentAppUser() == nil) {
            self.storageManager.createAppUser(email: "Guest", password: "none", isCurrent: true)
            return true
        }
        let currentAppUserEmail = self.storageManager.getCurrentUserEmail()

        if currentAppUserEmail == "Guest" {
            return true
        } else {
            return false
        }
    }
    
    func setNetworkMode(isActive: Bool) {
        self.userDefaultsManager.setNetworkMode(isActive: isActive)
    }
    
    func login(loginDto: LoginDto, completionHandler: @escaping (Result<String>) -> Void) {
        self.userDefaultsManager.setNetworkMode(isActive: true)
        let request = RequestFactory.BackendRequests.login(loginDto: loginDto)
        
        self.requestSender.send(requestConfig: request) { (loginResponseResult) in

            switch (loginResponseResult) {
            case .error(let error):
                completionHandler(.error(error))
            case .success(let loginResp):
                self.userDefaultsManager.saveToken(token: loginResp.accessToken)
                self.userDefaultsManager.saveEmail(email: loginResp.email)
                self.userDefaultsManager.saveTokenTimestamp(date: Date())
                let _ = self.storageManager.createAppUser(email: loginResp.email, password: loginDto.password, isCurrent: true)
                completionHandler(.success(loginResp.email))
            }
        }
    }
}
