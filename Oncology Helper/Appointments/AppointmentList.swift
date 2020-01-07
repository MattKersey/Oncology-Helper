//
//  AppointmentList.swift
//  Oncology Helper
//
//  View for listing appointments for a given date.
//
//  Created by Matt Kersey on 1/5/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentList: View {

    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @State private var isAddingAppointment = false
    let selectedDate: Date
    let userCalendar = Calendar.current
    
    var selectedDateAppointments: [Appointment] {
        var appointments: [Appointment] = []
        for apt in userData.appointments {
            if userCalendar.isDate(apt.date, inSameDayAs: selectedDate) {
                appointments.append(apt)
            }
        }
        return appointments
    }
    
    static let readableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    // MARK: - functions
    
    func delete(at offsets: IndexSet) {
        userData.appointments.remove(atOffsets: offsets)
    }
    
    // MARK: - body
    
    var body: some View {
        NavigationView {
            List {
                if (selectedDateAppointments.isEmpty) {
                    // If there are no appointments on the selected date, display appropriate message
                    Text("No appointments")
                        .foregroundColor(.gray)
                } else {
                    // Otherwise, show appointments
                    ForEach(self.userData.appointments) { appointment in
                        if (self.userCalendar.isDate(appointment.date, inSameDayAs: self.selectedDate)) {
                            NavigationLink(destination: AppointmentDetail(id: appointment.id).environmentObject(self.userData)) {
                                AppointmentRow(appointment: appointment)
                            }
                        }
                    }
                    .onDelete(perform: self.delete)
                }
            }
            .navigationBarTitle(Text("\(AppointmentList.readableDateFormatter.string(from: selectedDate))"))
            .navigationBarItems(trailing: Button(action: {self.isAddingAppointment = true}) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: self.$isAddingAppointment) {
                AppointmentAdder(date: self.selectedDate).environmentObject(self.userData)
            }
        }
    }
}

// MARK: - previews

struct AppointmentList_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentList(selectedDate: Date()).environmentObject(UserData())
    }
}
