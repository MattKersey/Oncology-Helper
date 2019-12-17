//
//  AppointmentDetail.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentDetail: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.editMode) var mode
    var appointment: Appointment
    
    var aptIndex: Int {
        userData.appointments.firstIndex(where: {$0.id == appointment.id})!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if self.mode?.wrappedValue == .inactive {
                AppointmentRow(appointment: appointment)
                Spacer()
            } else {
                AppointmentEditor(appointment: appointment).environmentObject(self.userData)
            }
        }
        .navigationBarItems(trailing: EditButton())
    }
}

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(appointment: appointmentData[0]).environmentObject(UserData())
    }
}
