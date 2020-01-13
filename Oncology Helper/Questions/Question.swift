//
//  Question.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/9/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct Question: Hashable, Codable, Identifiable {
    
    // MARK: - properties from JSON file
    
    var id: Int
    var questionString: String
    var description: String?
    var pin: Bool
    var appointmentTimestamps: [AppointmentTimestamps]
}

struct AppointmentTimestamps: Hashable, Codable, Identifiable {
    var id: Int
    var timestamps: [TimeInterval]
}
