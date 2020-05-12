import Foundation

/// Protocol for storing request info
protocol IRequest {
    /// `URLRequest` with configured data
    var url: URLRequest? { get }
}
