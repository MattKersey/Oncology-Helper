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

    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Binding var selectedDate: Date?
    let daysCurrentMonthInt: Int
    let daysPreviousMonthInt: Int
    let firstDayOfMonthIndex: Int
    let currentDayIndex: Int
    let currentWeekOrdinal: Int
    let todayDate: Date
    let firstDayOfMonthDate: Date
    let userCalendar: Calendar
    let shouldHighlightSelection: Bool
    
    // The relative date in the month, ie 31 of previous month is 0, 30 is -1
    var relativeDateInt: Int {
        1 + currentDayIndex + 7 * currentWeekOrdinal - firstDayOfMonthIndex
    }
    
    var actualDateInt: Int {
        // So we don't have to recalculate every time
        let rDInt = relativeDateInt
        // Check if the day is in the previous month
        if (rDInt <= 0) {
            // If so, return the date relative to that month
            return daysPreviousMonthInt + rDInt
        // Check if the day is in the next month
        } else if (rDInt > daysCurrentMonthInt) {
            // If so, return the date relative to that month
            return rDInt - daysCurrentMonthInt
        }
        // If the date is in the selected month, just give the relative date
        return rDInt
    }
    
    var isCurrentDateInMonth: Bool {
        // So we don't have to recalculate every time
        let rDInt = relativeDateInt
        // Return whether or not the relative date is out of range
        return !((rDInt <= 0) || (rDInt > daysCurrentMonthInt))
    }
    
    var actualDate: Date {
        // So we don't have to recalculate every time
        let relativeDate = relativeDateInt
        var month = firstDayOfMonthDate
        // Check if the day is in the previous month
        if (relativeDate <= 0) {
            // If so, go to the previous month
            month = month - TimeInterval(86400)
            // Set the month date to the start of the month
            month = userCalendar.date(from: userCalendar.dateComponents([.year, .month],
                                                                        from: month))!
        // Check if the day is in the next month
        } else if (relativeDate > daysCurrentMonthInt) {
            // If so, set the month date to the beginning of the next month
            month = userCalendar.date(byAdding: DateComponents(calendar: userCalendar, month: 1),
                                      to: month)!
        }
        // Return the month date with day filled in by the actual date number
        return userCalendar.date(bySetting: .day, value: actualDateInt, of: month)!
    }
    
    var isAppointmentDay: Bool {
        // So we don't have to recalculate every time
        let date = actualDate
        // Return true if there is an appointment for the selected day in the JSON file
        return (userData.appointments.first(where: {userCalendar.isDate($0.date, inSameDayAs: date)}) != nil)
    }

    // MARK: - body
    
    var body: some View {
        // So we don't have to recalculate every time
        let aptDay = isAppointmentDay
        let date = actualDate
        
        // The entire view is a button
        return Button(action: {self.selectedDate = date}) {
            ZStack {
                // Put a circle in the background to denote important things
                if shouldHighlightSelection && (self.selectedDate != nil) && userCalendar.isDate(date, inSameDayAs: self.selectedDate!) {
                    // If the day is selected, the circle is red
                    Image(systemName: "circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.red)
                        .opacity(0.25)
                } else if (userCalendar.isDate(date, inSameDayAs: todayDate)) {
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
                } else {
                    Image(systemName: "circle.fill")
                    .imageScale(.medium)
                    .opacity(0.0)
                }
                // The date number
                Text("\(actualDateInt)")
                    .font(.footnote)
                    .foregroundColor(.black)
            }
            // Change the opacity based on whether or not the day is in the selected month
            .opacity(isCurrentDateInMonth ? 1.0 : 0.5)
        }
    }
}

// MARK: - previews

struct CalendarDay_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDay(selectedDate: .constant(Date()),
                    daysCurrentMonthInt: 31,
                    daysPreviousMonthInt: 31,
                    firstDayOfMonthIndex: 4,
                    currentDayIndex: 0,
                    currentWeekOrdinal: 0,
                    todayDate: Date(),
                    firstDayOfMonthDate: Date(),
                    userCalendar: Calendar.current,
                    shouldHighlightSelection: false)
            .environmentObject(UserData())
    }
}
