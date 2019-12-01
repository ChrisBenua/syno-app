//
// Created by Ирина Улитина on 25.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

enum DateError: String, Error {
    case invalidDate
}

protocol IParser {
    associatedtype Model

    func parse(data: Data) -> Model?
}

class DefaultParser<T: Decodable>: IParser {
    typealias Model = T

    func parse(data: Data) -> T? {
        do {
            let coder = JSONDecoder()
            coder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            coder.keyDecodingStrategy = .convertFromSnakeCase
            let parsedObject = try coder.decode(T.self, from: data)
            return parsedObject
        }
        catch let DecodingError.dataCorrupted(context) {
            Logger.log("\(context)")
            return nil
        }
        catch let DecodingError.keyNotFound(key, context) {
            Logger.log("key: \(key), context: \(context)")
            return nil
        }
        catch let DecodingError.valueNotFound(value, context) {
            Logger.log("value: \(value), context: \(context)")
            return nil
        }
        catch let DecodingError.typeMismatch(type, context) {
            Logger.log("type: \(type), context: \(context)")
            return nil
        }
        catch let err {
            Logger.log("cant parse object of type \(T.self)")
            Logger.log(err.localizedDescription)
            return nil
        }
    }
}
