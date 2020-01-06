//
//  CalendarDay.swift
//  Oncology Helper
//
//  View for an individual day on the calendar.
//  Includes day number and a highlight
//
//  Created by Matt Kersey on 1/5/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarDay: View {
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData   // Variable for storing appointments, etc
    @Binding var selected: Date?                // Optional for holding a selected date
    
    let currentMonthDays: Int                   // Number of days in the selected month
    let previousMonthDays: Int                  // Number of days in the previous month
    let firstDayIndex: Int                      // Index in the week of the first day of the month
    let index: Int                              // Index of selected day in the week
    let ordinal: Int                            // Index of selected week in the month
    let currentDate: Date                       // The current date (today)
    let firstDay: Date                          // Date of the first day of the selected month
    let currentCalendar: Calendar               // Calendar
    let highlight: Bool                         // Whether dates get highlighted when selected
    
    var relativeDate_C: Int {                   // The relative date in the month, ie
        1 + index + 7 * ordinal - firstDayIndex     // 31 of previous month is 0, 30 is -1
    }
    
    var actualDateInt: Int {                    // Actual date number
        // So we don't have to recalculate every time
        let relativeDate = relativeDate_C
        // Check if the day is in the previous month
        if (relativeDate <= 0) {
            // If so, return the date relative to that month
            return previousMonthDays + relativeDate
        // Check if the day is in the next month
        } else if (relativeDate > currentMonthDays) {
            // If so, return the date relative to that month
            return relativeDate - currentMonthDays
        }
        // If the date is in the selected month, just give the relative date
        return relativeDate
    }
    
    var inMonth: Bool {                         // Whether or not the date is in selected month
        // So we don't have to recalculate every time
        let relativeDate = relativeDate_C
        // Return whether or not the relative date is out of range
        return !((relativeDate <= 0) || (relativeDate > currentMonthDays))
    }
    
    var actualDate: Date {                      // The actual date in date format
        // So we don't have to recalculate every time
        let relativeDate = relativeDate_C
        var month = firstDay
        // Check if the day is in the previous month
        if (relativeDate <= 0) {
            // If so, go to the previous month
            month = month - TimeInterval(86400)
            // Set the month date to the start of the month
            month = currentCalendar.date(from: currentCalendar.dateComponents([.year, .month], from: month))!
        // Check if the day is in the next month
        } else if (relativeDate > currentMonthDays) {
            // If so, set the month date to the beginning of the next month
            month = currentCalendar.date(byAdding: DateComponents(calendar: currentCalendar, month: 1), to: month)!
        }
        // Return the month date with day filled in by the actual date number
        return currentCalendar.date(bySetting: .day, value: actualDateInt, of: month)!
    }
    
    var isAppointmentDay: Bool {                   // Appointment on the selected day?
        // So we don't have to recalculate every time
        let date = actualDate
        // Return true if there is an appointment for the selected day in the JSON file
        return (userData.appointments.first(where: {currentCalendar.isDate($0.date, inSameDayAs: date)}) != nil)
    }

/**************************************** Main View ********************************************/
    
    var body: some View {
        // So we don't have to recalculate every time
        let aptDay = isAppointmentDay
        let date = actualDate
        
        // The entire view is a button
        return Button(action: {self.selected = date}) {
            ZStack {
                // Put a circle in the background to denote important things
                if highlight && (self.selected != nil) && (currentCalendar.isDate(date, inSameDayAs: self.selected!)) {
                    // If the day is selected, the circle is red
                    Image(systemName: "circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.red)
                        .opacity(0.25)
                } else if (currentCalendar.isDate(date, inSameDayAs: currentDate)) {
                    // If the day is today, the circle is blue (green if there is an appointment
                    Image(systemName: "circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(aptDay ? .green : .blue)
                        .opacity(0.25)
                } else if aptDay {
                    // If there is an appointment, the circle is yellow
                    Image(systemName: "circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.yellow)
                        .opacity(0.5)
                }
                // The date number
                Text("\(actualDateInt)")
                    .font(.footnote)
                    .foregroundColor(.black)
            }
            // Change the opacity based on whether or not the day is in the selected month
            .opacity(inMonth ? 1.0 : 0.5)
        }
    }
}

/**************************************** Preview ********************************************/

struct CalendarDay_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDay(selected: .constant(Date()), currentMonthDays: 31, previousMonthDays: 31, firstDayIndex: 4, index: 0, ordinal: 0, currentDate: Date(), firstDay: Date(), currentCalendar: Calendar.current, highlight: false).environmentObject(UserData())
    }
}
