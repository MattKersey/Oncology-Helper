//
//  Appointment.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import CoreLocation

struct Appointment: Hashable, Codable, Identifiable {
    var id: Int
    var doctor: String
    var location: String
    fileprivate var RC3339date: String
    var timestamps: [TimeInterval]
    var recordingURL: URL{
        URL(fileURLWithPath: "audioRecording\(self.id)")
    }
    
    static let `default` = UserData().appointments[0]
    
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
    
    var readableDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm MM/dd/yyyy"
        
        return formatter.string(from: date)
    }
}
