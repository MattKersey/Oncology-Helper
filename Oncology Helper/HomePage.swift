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
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @State var selectedDate: Date? = nil
    var todayDate = Date()
    
    // MARK: - body
    
    var body: some View {
        // Binding for when a date is selected
        let hasSelectedDate = Binding<Bool>(get: {
                self.selectedDate != nil
            }, set: { p in
                self.selectedDate = p ? Date() : nil
            })
        
        return VStack {
            // Calendar of appointments
            Text("Appointments")
                .font(.largeTitle)
            CalendarView(selectedDate: $selectedDate,
                         dayInMonthDate: todayDate,
                         shouldHighlightSelection: false)
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 250)
            Divider()
            Text("Questions")
                .font(.largeTitle)
            Spacer()
        }
        .sheet(isPresented: hasSelectedDate) {
            // Modal for when a date is selected
            AppointmentList(selectedDate: self.selectedDate!)
                .environmentObject(self.userData)
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserData())
    }
}
