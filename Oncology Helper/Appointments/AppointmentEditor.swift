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
    
    func save() -> Void {
        guard let aptIndex = appointmentIndex else {return}
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
        self.userData.appointments.sort(by: {$0.date < $1.date})
        self.presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - body
    
    var body: some View {
        guard appointmentIndex != nil else {
            return AnyView(Text("Appointment not found"))
        }
        return AnyView(VStack(spacing: 0) {
            List {
                VStack(alignment: .leading) {
                    Text("Doctor")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                        .padding(.top)
                    TextField("Doctor", text: $appointment.doctor)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding([.top, .bottom])
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    TextField("Location", text: $appointment.location)
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
            if appointment.doctor != "" && appointment.location != "" {
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
        AppointmentEditor(appointment: UserData().appointments[0], selectedTime: UserData().appointments[0].date).environmentObject(UserData())
    }
}
