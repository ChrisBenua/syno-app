//
//  VoiceNarrationService.swift
//  syno-mobile
//
//  Created by Christian Benua on 24.01.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import AVFoundation

protocol IVoiceNarrationService {
    func getNextCardUtterances() -> [AVSpeechUtterance]
}
