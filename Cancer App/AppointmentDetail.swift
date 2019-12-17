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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.editMode) var mode
    var id: Int
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == id}) {
            return apt
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if self.mode?.wrappedValue == .inactive {
                AppointmentRow(appointment: appointment!)
                Spacer()
            } else {
                AppointmentEditor(appointment: appointment!).environmentObject(self.userData)
            }
        }
        .navigationBarItems(trailing: EditButton())
    }
}

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(id: 1).environmentObject(UserData())
    }
}
