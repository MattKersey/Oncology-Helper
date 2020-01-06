//
//  HomePage.swift
//  Oncology Helper
//
//  Home page for the Oncology Helper app.
//  Contains an interactive calendar of appointment dates
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct HomePage: View {
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData   // Variable for storing appointments, etc
    @State var showAll = false                  // Whether we should show all apts or upcoming
    @State var selected: Date? = nil            // Optional for holding a selected date
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
        VStack {
            // Calendar of appointments
            Text("Appointments")
                .font(.largeTitle)
            CalendarView(selected: $selected, day: currentDate)
        }
            // Modal view for when a date is selected
        .sheet(isPresented: Binding<Bool>(get: {self.selected != nil}, set: {p in self.selected = p ? Date() : nil})) {
            AppointmentList(date: self.selected!).environmentObject(self.userData)
        }
    }
}

/**************************************** Preview ********************************************/

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserData())
    }
}
