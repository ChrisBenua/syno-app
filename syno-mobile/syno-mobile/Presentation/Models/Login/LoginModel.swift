import Foundation

/// Service protocol for handling inner logic of `LoginController`
protocol ILoginModel {
    /// Performs login
    /// - Parameter loginState: user's credentials
    func login(loginState: ILoginState)
    
    /// Notifies if user skipped registration
    func skippedRegistration()

    /// Event handler
    var controller: ILoginReactor? { get set }
}

class LoginModel: ILoginModel {
    var controller: ILoginReactor?

    /// Service for performing login request
    private let loginService: ILoginService

    /// Create new `LoginModel`
    /// - Parameter loginService: Service for performing login request
    init(loginService: ILoginService) {
        self.loginService = loginService
    }

    func skippedRegistration() {
        let didCreateGuestUser = loginService.createGuestUser()
        if (didCreateGuestUser) {
            loginService.setNetworkMode(isActive: false)
        }
        self.controller?.onSuccessfulLogin(email: self.loginService.currentUserEmail())
    }
    
    func login(loginState: ILoginState) {
        let loginDto = LoginDto(email: loginState.email, password: loginState.password)
        controller?.onStartedProcessingLogin()
        loginService.login(loginDto: loginDto) { (result) -> Void in
            switch (result) {
            case .error( _):
                DispatchQueue.main.async {
                    self.controller?.onFailedLogin()
                }
            case .success(let email):
                DispatchQueue.main.async {
                    self.controller?.onSuccessfulLogin(email: email)
                }
            }
        }
    }
}
