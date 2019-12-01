//
// Created by Ирина Улитина on 25.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation

struct RequestFactory {
    struct BackendRequests {
        static func login(loginDto: LoginDto) -> RequestConfig<DefaultParser<LoginResponseDto>> {
            return RequestConfig<DefaultParser<LoginResponseDto>>(request: LoginRequest(loginDto: loginDto), parser: DefaultParser())
        }
        
        static func allDictsRequest(userDefaultsManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<[GetDictionaryResponseDto]>> {
            return RequestConfig<DefaultParser<[GetDictionaryResponseDto]>>(request: AllDictsRequest(manager: userDefaultsManager), parser: DefaultParser())
        }
    }
}
