//
//  AppointmentRow.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentRow: View {
    
    // MARK: - instance properties
    
    var appointment: Appointment
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    // MARK: - body
    
    var body: some View {
        HStack(alignment: .top) {
            Text(dateFormatter.string(from: appointment.date))
            .font(.title)
            Divider()
            VStack(alignment: .leading) {
                Text(appointment.doctor)
                    .font(.headline)
                Text(appointment.location)
                    .font(.caption)
            }
            Spacer()
        }
    }
}

// MARK: - previews

struct AppointmentRow_Previews: PreviewProvider {

    static var previews: some View {
        
        AppointmentRow(appointment: appointmentData[0])
    }
}
