import Foundation

protocol IRegistrationReactor: class {
    /// Called when model started performing registration request
    func startedProcessingRegistration()
    
    /// Called when model failed to perform registration request
    func failed(error: String)
    
    /// Called when model performed registration successfully
    func success()
}

protocol IRegistrationModel {
    func register()
    
    var state: IRegisterState { get }
    
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
                    self.reactor?.success()
                case .error(let str):
                    self.reactor?.failed(error: str)
                }
            }
        }
    }
    
    var state: IRegisterState
    
    weak var reactor: IRegistrationReactor?
    
    private var registerService: IRegisterService
    
    init(registerService: IRegisterService) {
        self.state = RegisterState()
        self.registerService = registerService
    }
}
