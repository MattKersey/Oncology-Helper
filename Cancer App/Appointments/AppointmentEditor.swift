//
//  AppointmentEditor.swift
//  Oncology Helper
//
//  File for facilitating edits to an appointment
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentEditor: View {
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var appointment: Appointment                // Temporary storage for possible cancellation
    
    var aptIndex: Int? {                        // Index of the appointment in the array
        // Check to see if something went wrong, if so dismiss this view
        if let index = userData.appointments.firstIndex(where: {$0.id == appointment.id}) {
            return index
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
/**************************************** Functions ********************************************/
    
    /*
     Function for cancelling an edit and returning to initial values
     TODO: Make this actually work
     */
    func cancel() -> Void {
        userData.appointments[aptIndex!].doctor = appointment.doctor
        userData.appointments[aptIndex!].location = appointment.location
        userData.appointments[aptIndex!].date = appointment.date
        self.presentationMode.wrappedValue.dismiss()
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        List {
            // Doctor name field
            HStack {
                Text("Doctor")
                    .font(.headline)
                Divider()
                TextField("Doctor", text: $userData.appointments[aptIndex!].doctor)
            }
            // Location name field
            HStack {
                Text("Location")
                    .font(.headline)
                Divider()
                TextField("Location", text: $userData.appointments[aptIndex!].location)
            }
            // Date picker for appointment
            DatePicker(selection: $userData.appointments[aptIndex!].date, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
            
            // Cancel button
            Button(action: {self.cancel()}) {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        // For ensuring that the array is sorted on a date change
        .onDisappear(perform: {self.userData.appointments.sort(by: {$0.date < $1.date})})
    }
}

struct AppointmentEditor_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEditor(appointment: UserData().appointments[0]).environmentObject(UserData())
    }
}
