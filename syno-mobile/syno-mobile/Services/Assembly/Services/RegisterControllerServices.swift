import Foundation

/// Protocol for handling registration
protocol IRegisterService {
    /**
     Perform registration
     - Parameter registerDto: user credentials
     - Parameter completionHandler: completion callback
     */
    func register(registerDto: RegisterDto, completionHandler: ((Result<String>) -> Void)?)
}

/// Class for handling registration
class RegisterService: IRegisterService {
    
    private let requestSender: IRequestSender
    
    /**
     Creates new RegisterService
     - Parameter requestSender: instance for completing web requests
     */
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func register(registerDto: RegisterDto, completionHandler: ((Result<String>) -> Void)?) {
        requestSender.send(requestConfig: RequestFactory.BackendRequests.register(registerDto: registerDto)) { (resp) -> Void in
            switch resp {
            case .success(let model):
                completionHandler?(.success(model.message))
            case .error(let str):
                completionHandler?(.error(str))
            }
        }
    }
    
    
}
