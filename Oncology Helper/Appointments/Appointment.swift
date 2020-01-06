//
//  Appointment.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import CoreLocation

struct Appointment: Hashable, Codable, Identifiable {
/*********************************** Variables from JSON File ***************************************/
    
    var id: Int                                 // The appointment's id
    var doctor: String                          // Doctor's name
    var location: String                        // Name of hospital or practice
    fileprivate var RC3339date: String          // Date in yyyy-MM-dd'T'HH:mm:ssZZZZZ format
    var hasRecording: Bool                      // Is there a recording of the appointment?
    var timestamps: [TimeInterval]              // List of timestamps in recording
    
/************************************ Computed Properties ****************************************/
    
    static let `default` = UserData().appointments[0]
    
    var recordingURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("audioRecording\(self.id).m4a")
    }
    
    var date: Date {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return formatter.date(from: RC3339date)!
        }
        set(newDate) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            RC3339date = formatter.string(from: newDate)
        }
    }
    
    init(id: Int, doctor: String, location: String, RC3339date: String) {
        self.id = id
        self.doctor = doctor
        self.location = location
        self.RC3339date = RC3339date
        self.hasRecording = false
        self.timestamps = []
    }
}
