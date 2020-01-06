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

    
    @EnvironmentObject var userData: UserData
    @State var addAppointment = false
    var date: Date
    var currentCalendar = Calendar.current
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }
    
    func delete(at offsets: IndexSet) {
        userData.appointments.remove(atOffsets: offsets)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.userData.appointments) { appointment in
                    if (self.currentCalendar.isDate(appointment.date, inSameDayAs: self.date)) {
                        NavigationLink(destination: AppointmentDetail(id: appointment.id).environmentObject(self.userData)
                        ) {
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
                .onDelete(perform: self.delete)
            }
        .navigationBarTitle(Text("\(dateFormatter.string(from: date))"))
            .navigationBarItems(
                trailing: Button(action: {self.addAppointment = true}) {Image(systemName: "plus")})
                .sheet(isPresented: self.$addAppointment) {AppointmentAdder(date: self.date).environmentObject(self.userData)
            }
        }
    }
}

struct AppointmentList_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentList(date: Date()).environmentObject(UserData())
    }
}
