//
//  Appointment.swift
//  Oncology Helper
//
//  Data structure for holding key values related to appointments
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

class Appointment: Hashable, Codable, Identifiable {

    static let `default` = UserData().appointments[0]
    
    // MARK: - instance properties
    
    var id: Int
    var doctor: String
    var location: String
    fileprivate var RC3339date: String
    var describedTimestamps: [DescribedTimestamp]
    var questionIDs: [Int]
    
    var recordingURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("OHaudioRecording\(id).m4a")
    }
    
    var hasRecording: Bool {
        return FileManager.default.fileExists(atPath: recordingURL.path)
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
    
    // MARK: - functions
    
    static func == (lhs: Appointment, rhs: Appointment) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - initializer
    
    init(id: Int, doctor: String, location: String, RC3339date: String) {
        self.id = id
        self.doctor = doctor
        self.location = location
        self.RC3339date = RC3339date
        self.describedTimestamps = []
        self.questionIDs = []
    }
}

struct DescribedTimestamp: Hashable, Codable {
    var id: Int?
    var description: String?
    var timestamp: TimeInterval
}
