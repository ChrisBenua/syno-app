//
// Created by Ирина Улитина on 25.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation
import Alamofire

class DefaultRequestSender: IRequestSender {


    private let session: URLSession = URLSession.shared

    func send<Parser>(requestConfig: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model>) -> Void) {
        guard let url = requestConfig.request.url else {
            completionHandler(Result.error("url string can't be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: url) { (data, resp, err) in
            if let err = err {
                Logger.log("Error happened when queried \(url.url!.absoluteString)")
                Logger.log(String(data: data ?? String("no data").data(using: .utf8)!, encoding: .utf8)!)
                Logger.log(err.localizedDescription)
                completionHandler(Result.error(err.localizedDescription))
                return
            }

            if let httpResponse = resp as? HTTPURLResponse {
                if !(200...300).contains(httpResponse.statusCode) {
                    Logger.log("Not 200 status code for \(Parser.self)")
                    guard let unwrappedData = data, let message = try? JSONSerialization.jsonObject(with: unwrappedData, options: .allowFragments) as? [String: String] else {
                        completionHandler(.error("not 200 status code"))
                        return
                    }
                    completionHandler(.error(message["message"]!))
                    return
                }
            } else {
                Logger.log("urlResponse cant be represented as HTTPURLResponse")
            }
            
            
            guard let unwrappedData = data,
                let parsedModel: Parser.Model = requestConfig.parser.parse(data: unwrappedData)
                else {
                    Logger.log(String(data: data!, encoding: .utf8)!)
                    completionHandler(Result.error("received data cant be parsed"))
                    return
            }
            
            completionHandler(Result.success(parsedModel))
        }
        task.resume();
    }
}
