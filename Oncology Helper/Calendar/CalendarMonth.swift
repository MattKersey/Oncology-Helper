//
//  CalendarMonth.swift
//  Cancer App
//
//  A view that takes in a day in a month and prints that month
//  in a calendar format.
//
//  Created by Matt Kersey on 1/5/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarMonth: View {
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData   // Variable for storing appointments, etc
    @Binding var selected: Date?                // Optional for holding a selected date
    var day: Date                               // Variable for holding some day in a month
    
    var weekDays: [String] = ["S", "M", "T", "W", "T", "F", "S"]    // Weekday abbreviations
    
    let currentCalendar = Calendar.current      // Variable for holding a calendar
    
    var dateFormatter: DateFormatter {          // Formatter for getting the day from a date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd"
        return formatter
    }
    
    var firstDay_C: Date {                      // Date of the first day of the selected month
        let monthComponents = currentCalendar.dateComponents([.year, .month], from: day)
        return currentCalendar.date(from: monthComponents)!
    }
    
    var currentMonthDays_C: Int {               // Number of days in the selected month
        // Get the first day of the next month
        let firstDayNextMonth = currentCalendar.date(byAdding: DateComponents(calendar: currentCalendar, month: 1), to: firstDay_C)!
        // Get the final day of this month
        let finalDay = firstDayNextMonth - TimeInterval(86400)
        // The number of days in the month should be equal to the number of the final day
        return Int(dateFormatter.string(from: finalDay))!
    }
    
    var previousMonthDays_C: Int {              // Number of days in the previous month
        // Find the final day of the previous month
        let finalDay = firstDay_C - TimeInterval(86400)
        // The number of days in the month should be equal to the number of the final day
        return Int(dateFormatter.string(from: finalDay))!
    }
    
    var firstDayIndex_C: Int {                  // Index in the week of the first day of the month
        let dayIndex = currentCalendar.component(.weekday, from: firstDay_C)
        // .weekday is indexed from 1
        return dayIndex - 1
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        // Get variables for the computed properties so we don't recalculate every time
        let currentMonthDays = currentMonthDays_C
        let previousMonthDays = previousMonthDays_C
        let firstDayIndex = firstDayIndex_C
        let firstDay = firstDay_C
        
        return HStack(alignment: .top, spacing: 20) {
            // Loop through every weekday first
            ForEach(self.weekDays.indices) { index in
                VStack {
                    // Title with weekday abbreviation
                    Text(self.weekDays[index])
                        .font(.subheadline)
                    // Now loop through that weekday in the context of the whole month
                    // Assume each month is 6 weeks for sake of consistent UI
                    ForEach(0 ..< 6) { ordinal in
                        // View for each day
                        CalendarDay(selected: self.$selected, currentMonthDays: currentMonthDays, previousMonthDays: previousMonthDays, firstDayIndex: firstDayIndex, index: index, ordinal: ordinal, currentDate: Date(), firstDay: firstDay, currentCalendar: self.currentCalendar).environmentObject(self.userData)
                    }
                }
                // We only want dividers in between weekdays, not at the end
                if (index < self.weekDays.count - 1) {
                    Divider()
                }
            }
        }
    }
}

/**************************************** Preview ********************************************/

struct CalendarMonth_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMonth(selected: .constant(Date()), day: Date()).environmentObject(UserData())
    }
}
