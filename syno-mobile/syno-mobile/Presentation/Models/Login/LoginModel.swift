import Foundation

protocol ILoginModel {
    func login(loginState: ILoginState)
    
    func skippedRegistration()

    var controller: ILoginReactor? { get set }
}

class LoginModel: ILoginModel {
    var controller: ILoginReactor?

    private let loginService: ILoginService

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
