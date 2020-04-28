import Foundation

protocol ILoginState {
    var email: String {get}
    var password: String {get}
}

struct LoginState: ILoginState {
    let email: String
    
    let password: String
}

