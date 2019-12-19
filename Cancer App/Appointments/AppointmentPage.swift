//
//  AppointmentPage.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/18/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentPage: View {
    var appointment: Appointment
    
    var body: some View {
        List {
            AppointmentRow(appointment: appointment)
            AppointmentRecording(id: 0).environmentObject(UserData())
        }
    }
}

struct AppointmentPage_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentPage(appointment: UserData().appointments[0])
    }
}
