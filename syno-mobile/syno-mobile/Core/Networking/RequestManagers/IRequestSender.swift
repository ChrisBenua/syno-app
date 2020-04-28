import Foundation


protocol IRequestConfig {
    associatedtype Parser: IParser

    var request: IRequest { get }
    var parser: Parser { get }
}

struct RequestConfig<Parser: IParser>: IRequestConfig {
    let request: IRequest
    let parser: Parser
}


protocol IRequestSender {
    func send<Parser>(requestConfig: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model>) -> Void)
}

enum Result<Model> {
    case success(Model)
    case error(String)
}
