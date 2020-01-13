//
//  UserData.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation

final class UserData: ObservableObject {
    @Published var appointments = appointmentData
    @Published var questions = questionData
    @Published var audioSession: AVAudioSession?
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession!.setCategory(.playAndRecord, mode: .default)
            try audioSession!.setActive(true)
            audioSession!.requestRecordPermission() { allowed in
                if !allowed {
                    self.audioSession = nil
                }
            }
        } catch {
            audioSession = nil
        }
    }
}
