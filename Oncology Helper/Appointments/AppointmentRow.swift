//
//  AppointmentRow.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentRow: View {
    var appointment: Appointment
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(appointment.doctor)
                    .font(.headline)
                HStack {
                    Text(appointment.readableDate)
                    Spacer()
                    Text(appointment.location)
                }
                .font(.caption)
            }
        }
    }
}

struct AppointmentRow_Previews: PreviewProvider {

    static var previews: some View {
        
        AppointmentRow(appointment: appointmentData[0])
    }
}
