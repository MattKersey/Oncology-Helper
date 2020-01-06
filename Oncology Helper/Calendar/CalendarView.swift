//
//  CalendarView.swift
//  Oncology Helper
//
//  A calendar for sorting appointments by date.
//  Ideally more intuitive than a list or picker.
//
//  Created by Matt Kersey on 12/17/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
/**************************************** Variables ********************************************/

    @EnvironmentObject var userData: UserData   // Variable for storing appointments, etc
    @Binding var selected: Date?                // Optional for holding a selected date
    @State var day: Date                        // Variable for holding some day in a month
    @State var increment = true                 // State variable used for transitions
                                                    // TODO: Add transitions
    let currentCalendar = Calendar.current      // Variable for holding a calendar
    
    var month: String {                         // String containing the selected month
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: day)
    }
    
    var year: String {                          // String containing the selected year
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: day)
    }
    
    var firstDay_C: Date {                      // Date of the first day of the selected month
        let monthComponents = currentCalendar.dateComponents([.year, .month], from: day)
        return currentCalendar.date(from: monthComponents)!
    }
    
/**************************************** Functions ********************************************/
    
    /*
     Function for moving to the next month
    */
    func incrementMonth() -> Void {
        // Set state for transitions
        increment = true
        // Add one month to the current day
        day = currentCalendar.date(byAdding: DateComponents(calendar: currentCalendar, month: 1), to: firstDay_C)!
        // set the day to the first of the month
        day = firstDay_C
    }
    
    /*
     Function for moving to the previous month
    */
    func decrementMonth() -> Void {
        // Set state for transitions
        increment = false
        // Subtract one day from the first day of the month (ie last day of previous month)
        day = firstDay_C - TimeInterval(86400)
        // Set the day to the first of the month
        day = firstDay_C
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        VStack {
            // Header for the calendar containing buttons for changing month and title
            HStack {
                // Decrement month button
                Button(action: {self.decrementMonth()}) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                // Name of month and year
                Text("\(month) \(year)")
                Spacer()
                // Increment month button
                Button(action: {self.incrementMonth()}) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            // View of days in the selected month
            CalendarMonth(selected: self.$selected, day: firstDay_C).environmentObject(self.userData)
        }
    }
}

/**************************************** Preview ********************************************/

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(selected: .constant(nil), day: Date()).environmentObject(UserData())
    }
}
