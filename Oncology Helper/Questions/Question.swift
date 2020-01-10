//
//  Question.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/9/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct Question: Hashable, Codable, Identifiable {
    var id: Int
    var question: String
    var doctor: String?
    var pin: Bool
    var appointmentTimestamps: [AppointmentTimestamps]
}

struct AppointmentTimestamps: Hashable, Codable, Identifiable {
    var id: Int
    var timestamps: [TimeInterval]
}
