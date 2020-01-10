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
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var appointment: Appointment                // Temporary storage for possible cancellation
    @State var selectedDate: Date? = nil
    @State var selectedTime: Date
    
    var appointmentIndex: Int? {
        if let index = userData.appointments.firstIndex(where: {$0.id == appointment.id}) {
            return index
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    // MARK: - functions
    
    func cancel() -> Void {
        guard let aptIndex = appointmentIndex else {
            return
        }
        appointment.doctor = userData.appointments[aptIndex].doctor
        appointment.location = userData.appointments[aptIndex].location
        selectedDate = nil
        selectedTime = userData.appointments[aptIndex].date
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func save() -> Void {
        guard let aptIndex = appointmentIndex else {
            return
        }
        userData.appointments[aptIndex].doctor = appointment.doctor
        userData.appointments[aptIndex].location = appointment.location
        if (selectedDate != nil) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate!)
            components.hour = calendar.component(.hour, from: selectedTime)
            components.minute = calendar.component(.minute, from: selectedTime)
            userData.appointments[aptIndex].date = calendar.date(from: components)!
        } else {
            userData.appointments[aptIndex].date = appointment.date
        }
    }
    
    // MARK: - body
    
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
                CalendarView(selectedDate: $selectedDate, dayInMonthDate: Date(), shouldHighlightSelection: true)
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

// MARK: - previews

struct AppointmentEditor_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEditor(appointment: UserData().appointments[0], selectedTime: UserData().appointments[0].date).environmentObject(UserData())
    }
}
