import Foundation

/// Protocol for logging messages
protocol Loggable {
  func debugOutput(_ message: String)
}

/// Actual debug logger that prints messages in Developer console
class DebugLogger: Loggable {
  func debugOutput(_ message: String) {
    let date = Date()
    let df = DateFormatter()
    df.dateFormat = "HH:mm:ss.SSS"
    let dateString = df.string(from: date)
    print(dateString + ":   " + message)
  }
}

/// In Release version Logger doesnt do anything to increase perfomance
class ReleaseLogger: Loggable {
  func debugOutput(_ message: String) {}
}

/// Class for accessing needed logger
class Logger {

  private static let shared = Logger()

  private lazy var logger: Loggable = {
    #if DEBUG
    return DebugLogger()
    #else
    return ReleaseLogger()
    #endif
  }()

  func log(_ message: String) {
    logger.debugOutput(message)
  }

  public static func log(_ message: String) {
    shared.log(message)
  }
}
