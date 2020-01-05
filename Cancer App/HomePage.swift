//
//  HomePage.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct HomePage: View {
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData   // Variable for storing appointments, etc
    @State var showAll = false                  // Whether we should show all apts or upcoming
    @State var addAppointment = false           // Whether user is adding an appointment
    var currentDate = Date()                    // Current date to determine if upcoming
    
/**************************************** Functions ********************************************/
    
    /*
     Function for deleting appointments
     TODO: Add functionality for deleting associated audio files, memos
     */
    func delete(at offsets: IndexSet) {
        userData.appointments.remove(atOffsets: offsets)
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        NavigationView {
            List {
                // Appointments loop
                ForEach(self.userData.appointments) { appointment in
                    // Check if the appointment should be shown (it's upcoming or show all)
                    if self.showAll || appointment.date > self.currentDate {
                        NavigationLink(destination: AppointmentDetail(id: appointment.id).environmentObject(self.userData)
                        ) {
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
                .onDelete(perform: self.delete)
            }
            .navigationBarTitle(self.showAll ? Text("All Appointments") : Text("Upcoming"))
            .navigationBarItems(leading: Button(action: {self.showAll.toggle()}){self.showAll ? Text("Show Upcoming") : Text("Show All")}, trailing: Button(action: {self.addAppointment = true}) {
                    Image(systemName: "plus")
            })
            .sheet(isPresented: self.$addAppointment) {
                        AppointmentAdder().environmentObject(self.userData)
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserData())
    }
}
