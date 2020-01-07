//
//  CalendarMonth.swift
//  Oncology Helper
//
//  A view that takes in a day in a month and prints that month
//  in a calendar format.
//
//  Created by Matt Kersey on 1/5/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarMonth: View {

    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Binding var selectedDate: Date?
    let dayInMonthDate: Date
    let shouldHighlightSelection: Bool
    
    let weekDaysStrings: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    let userCalendar = Calendar.current
    
    var dayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd"
        return formatter
    }
    
    var firstDayOfMonthDate: Date {
        let monthComponents = userCalendar.dateComponents([.year, .month],
                                                          from: dayInMonthDate)
        return userCalendar.date(from: monthComponents)!
    }
    
    var daysCurrentMonthInt: Int {
        // Get the first day of the next month
        let components = DateComponents(calendar: userCalendar, month: 1)
        let firstDayNextMonth = userCalendar.date(byAdding: components,
                                                  to: firstDayOfMonthDate)!
        // Get the final day of this month
        let finalDay = firstDayNextMonth - TimeInterval(86400)
        return Int(dayDateFormatter.string(from: finalDay))!
    }
    
    var daysPreviousMonthInt: Int {
        // Find the final day of the previous month
        let finalDay = firstDayOfMonthDate - TimeInterval(86400)
        return Int(dayDateFormatter.string(from: finalDay))!
    }
    
    var firstDayOfMonthIndex: Int {
        let dayIndex = userCalendar.component(.weekday,
                                              from: firstDayOfMonthDate)
        // .weekday is indexed from 1
        return dayIndex - 1
    }
    
    // MARK: - body
    
    var body: some View {
        // Get variables for the computed properties so we don't recalculate
        let currentMonthDays = daysCurrentMonthInt
        let previousMonthDays = daysPreviousMonthInt
        let firstDayIndex = firstDayOfMonthIndex
        let firstDay = firstDayOfMonthDate
        
        return HStack(alignment: .top, spacing: 20) {
            // Loop through every weekday first
            ForEach(self.weekDaysStrings.indices) { index in
                VStack {
                    // Title with weekday abbreviation
                    Text(self.weekDaysStrings[index])
                        .font(.subheadline)
                    // Assume each month is 6 weeks for sake of consistent UI
                    ForEach(0 ..< 6) { ordinal in
                        CalendarDay(selectedDate: self.$selectedDate,
                                    daysCurrentMonthInt: currentMonthDays,
                                    daysPreviousMonthInt: previousMonthDays,
                                    firstDayOfMonthIndex: firstDayIndex,
                                    currentDayIndex: index,
                                    currentWeekOrdinal: ordinal,
                                    todayDate: Date(),
                                    firstDayOfMonthDate: firstDay,
                                    userCalendar: self.userCalendar,
                                    shouldHighlightSelection: self.shouldHighlightSelection)
                            .environmentObject(self.userData)
                    }
                }
                // We only want dividers in between weekdays, not at the end
                if (index < self.weekDaysStrings.count - 1) {
                    Divider()
                }
            }
        }
    }
}

// MARK: - previews

struct CalendarMonth_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMonth(selectedDate: .constant(Date()),
                      dayInMonthDate: Date(),
                      shouldHighlightSelection: false)
            .environmentObject(UserData())
    }
}
