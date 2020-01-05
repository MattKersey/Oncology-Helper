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
    @State var appointment: Appointment                // Temporary storage for possible cancellation
    @State var selectedDate: Date? = nil
    @State var selectedTime: Date
    
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
     */
    func cancel() -> Void {
        appointment.doctor = userData.appointments[aptIndex!].doctor
        appointment.location = userData.appointments[aptIndex!].location
        selectedDate = nil
        selectedTime = userData.appointments[aptIndex!].date
        self.presentationMode.wrappedValue.dismiss()
    }
    
    /*
     Function for saving changes, automatically called when the view disappears
     */
    func save() -> Void {
        userData.appointments[aptIndex!].doctor = appointment.doctor
        userData.appointments[aptIndex!].location = appointment.location
        if (selectedDate != nil) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate!)
            components.hour = calendar.component(.hour, from: selectedTime)
            components.minute = calendar.component(.minute, from: selectedTime)
            userData.appointments[aptIndex!].date = calendar.date(from: components)!
        } else {
            userData.appointments[aptIndex!].date = appointment.date
        }
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        return VStack {
            List {
                // Doctor name field
                HStack {
                    Text("Doctor")
                        .font(.headline)
                    Divider()
                    TextField("Doctor", text: $appointment.doctor)
                }

                // Location name field
                HStack {
                    Text("Location")
                        .font(.headline)
                    Divider()
                    TextField("Location", text: $appointment.location)
                }

                // Date picker for appointment
                // DatePicker(selection: $appointment.date, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
                CalendarView(selected: $selectedDate, day: Date())
                if (selectedDate != nil) {
                    DatePicker(selection: $selectedTime, displayedComponents: .hourAndMinute, label: {Text("Time")})
                }
            }
            Spacer()
            // Done button
            Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            
            Divider()
            
            // Cancel button
            Button(action: {self.cancel()}) {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .padding(.bottom)
        }
            .buttonStyle(BorderlessButtonStyle())
            // For ensuring that the array is sorted on a date change
            .onDisappear(perform: {self.save(); self.userData.appointments.sort(by: {$0.date < $1.date})})
    }
}

struct AppointmentEditor_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEditor(appointment: UserData().appointments[0], selectedTime: UserData().appointments[0].date).environmentObject(UserData())
    }
}
