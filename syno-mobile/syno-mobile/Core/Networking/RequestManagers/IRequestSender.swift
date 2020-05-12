import Foundation

/// Service Protocol for storing web request configuration
protocol IRequestConfig {
    associatedtype Parser: IParser

    /// Actual request configuration
    var request: IRequest { get }
    /// Request result parser
    var parser: Parser { get }
}

struct RequestConfig<Parser: IParser>: IRequestConfig {
    let request: IRequest
    let parser: Parser
}

/// Service protocol for sending requests
protocol IRequestSender {
    /**
     Sends request
     - Parameters:
        - requestConfig: request configuration
        - completionHandler: completion callback
     */
    func send<Parser>(requestConfig: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model>) -> Void)
}

enum Result<Model> {
    case success(Model)
    case error(String)
}
