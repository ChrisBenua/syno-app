//
// Created by Ирина Улитина on 25.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation

protocol Loggable {
    func debugOutput(_ message: String)
}

class DebugLogger: Loggable {
    func debugOutput(_ message: String) {
        print(message)
    }
}

class ReleaseLogger: Loggable {
    func debugOutput(_ message: String) {}
}

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