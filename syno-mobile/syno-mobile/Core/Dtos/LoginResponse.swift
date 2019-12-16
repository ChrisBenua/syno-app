//
// Created by Ирина Улитина on 26.11.2019.
// Copyright (c) 2019 Christian Benua. All rights reserved.
//

import Foundation

struct LoginResponseDto: Decodable {
    let accessToken: String
    let email: String
}
