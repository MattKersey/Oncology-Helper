//
//  AppointmentEditor.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentEditor: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var appointment: Appointment
    
    var aptIndex: Int? {
        userData.appointments.firstIndex(where: {$0.id == appointment.id})
    }
    
    func delete() -> Void {
        userData.appointments.remove(at: aptIndex!)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        List {
            if (aptIndex != nil) {
                HStack {
                    Text("Doctor")
                    Divider()
                    TextField("Doctor", text: $userData.appointments[aptIndex!].doctor)
                }

                HStack {
                    Text("Location")
                    Divider()
                    TextField("Location", text: $userData.appointments[aptIndex!].location)
                }

                Button(action: {self.delete()}) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

struct AppointmentEditor_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEditor(appointment: UserData().appointments[0]).environmentObject(UserData())
    }
}
