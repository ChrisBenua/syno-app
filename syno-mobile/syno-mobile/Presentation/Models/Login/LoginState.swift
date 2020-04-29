import Foundation

/// Protocol for storing Login form state
protocol ILoginState {
    /// Entered email
    var email: String {get}
    /// Entered password
    var password: String {get}
}

struct LoginState: ILoginState {
    let email: String
    
    let password: String
}

