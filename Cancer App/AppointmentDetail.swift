//
//  AppointmentDetail.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentDetail: View {
    var appointment: Appointment
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                EditButton()
            }
            .padding()
            AppointmentRow(appointment: appointment)
            Spacer()
        }
    }
}

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(appointment: appointmentData[0])
    }
}
