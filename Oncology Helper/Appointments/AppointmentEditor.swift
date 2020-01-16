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
    @State var selectedDate: Date? = nil
    @State var selectedTime: Date
    @State var doctor: String
    @State var location: String
    var appointment: Appointment
    
    init(appointment: Appointment, selectedTime: Date) {
        self.appointment = appointment
        _selectedTime = State(initialValue: selectedTime)
        _doctor = State(initialValue: appointment.doctor)
        _location = State(initialValue: appointment.location)
    }
    
    // MARK: - functions
    
    func save() -> Void {
        appointment.doctor = doctor
        appointment.location = location
        if (selectedDate != nil) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate!)
            components.hour = calendar.component(.hour, from: selectedTime)
            components.minute = calendar.component(.minute, from: selectedTime)
            appointment.date = calendar.date(from: components)!
            self.userData.appointments.sort(by: {$0.date < $1.date})
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - body
    
    var body: some View {
        return AnyView(VStack(spacing: 0) {
            List {
                VStack(alignment: .leading) {
                    Text("Doctor")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                        .padding(.top)
                    TextField("Doctor", text: $doctor)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding([.top, .bottom])
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    TextField("Location", text: $location)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                    .padding([.top, .bottom])
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    CalendarView(selectedDate: $selectedDate, dayInMonthDate: Date(), shouldHighlightSelection: true)
                }
                if (selectedDate != nil) {
                    DatePicker(selection: $selectedTime, displayedComponents: .hourAndMinute, label: {Text("Time")})
                }
            }
            Spacer()
            Divider()
            // Cancel button
            Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .frame(height: 60)
            
            // Done button
            if doctor != "" && location != "" {
                Button(action: {self.save()}) {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(height: 60)
                    .background(Constants.itemColor)
                }
            } else {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 60)
                .background(Constants.subtitleColor)
            }
        }
        .buttonStyle(BorderlessButtonStyle()))
    }
}

// MARK: - previews

struct AppointmentEditor_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEditor(appointment: Appointment.default, selectedTime: UserData().appointments[0].date).environmentObject(UserData())
    }
}
