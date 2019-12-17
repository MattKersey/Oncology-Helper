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
    fileprivate var coordinates: Coordinates
    
    static let `default` = UserData().appointments[0]//Self(id: 1, doctor: "Shefali Gladson", location: "Kingsbrook Jewish Medical Center", RC3339date: "2020-03-15T13:30:00+03:00", coordinates: Coordinates(longitude: 0.000, latitude: 0.000))
    
    var date: Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return formatter.date(from: RC3339date)!
    }
    
    var readableDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm MM/dd/yyyy"
        
        return formatter.string(from: date)
    }
    
    var locationCoordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }
}

struct Coordinates: Hashable, Codable {
    var longitude: Double
    var latitude: Double
}
