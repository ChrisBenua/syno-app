import Foundation

/// Protocol for `IRegistrationModel` event handling
protocol IRegistrationReactor: class {
    /// Called when model started performing registration request
    func startedProcessingRegistration()
    
    /// Called when model failed to perform registration request
    func failed(error: String)
    
    /// Called when model performed registration successfully
    func success()
}

/// Protocol for perfomring registration
protocol IRegistrationModel {
    /// Performs registration
    func register()
    /// Stores current form state
    var state: IRegisterState { get }
    
    /// Event handler
    var reactor: IRegistrationReactor? { get set }
}

class RegistrationModel: IRegistrationModel {
    func register() {
        let dto = RegisterDto(email: self.state.email, password: self.state.password)
        self.reactor?.startedProcessingRegistration()
        
        self.registerService.register(registerDto: dto) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.userDefaultsManager.saveRegisterEmail(email: self.state.email.trimmingCharacters(in: .whitespacesAndNewlines))
                    self.reactor?.success()
                case .error(let str):
                    self.reactor?.failed(error: str)
                }
            }
        }
    }
    
    var state: IRegisterState
    
    let userDefaultsManager: IUserDefaultsManager
    
    weak var reactor: IRegistrationReactor?
    
    /// Service for performing registration request to server
    private var registerService: IRegisterService
    
    /**
     Creates new `RegistrationModel`
     - Parameter registerService: Service for performing registration request to server
     */
    init(registerService: IRegisterService, userDefaultsManager: IUserDefaultsManager) {
        self.state = RegisterState()
        self.userDefaultsManager = userDefaultsManager
        self.registerService = registerService
    }
}
