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

    // MARK: - instance properties

    @EnvironmentObject var userData: UserData
    @Binding var selectedDate: Date?                
    @State var dayInMonthDate: Date
    let shouldHighlightSelection: Bool
    let userCalendar = Calendar.current
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: dayInMonthDate)
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: dayInMonthDate)
    }
    
    var firstDayOfMonthDate: Date {
        let monthComponents = userCalendar.dateComponents([.year, .month],
                                                          from: dayInMonthDate)
        return userCalendar.date(from: monthComponents)!
    }
    
    // MARK: - functions
    
    /**
     Function for moving to the next month
    */
    func incrementMonth() -> Void {
        // Add one month to the current day
        dayInMonthDate = userCalendar.date(byAdding: DateComponents(calendar: userCalendar, month: 1),
                                           to: firstDayOfMonthDate)!
        // set the day to the first of the month
        dayInMonthDate = firstDayOfMonthDate
    }
    
    /**
     Function for moving to the previous month
    */
    func decrementMonth() -> Void {
        // Subtract one day from the first day of the month
        dayInMonthDate = firstDayOfMonthDate - TimeInterval(86400)
        // Set the day to the first of the month
        dayInMonthDate = firstDayOfMonthDate
    }
    
    // MARK: - body
    
    var body: some View {
        VStack {
            // Header for the calendar
            HStack {
                // Decrement month button
                Button(action: {self.decrementMonth()}) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                // Name of month and year
                Text("\(monthString) \(yearString)")
                .font(.headline)
                .foregroundColor(Constants.titleColor)
                Spacer()
                // Increment month button
                Button(action: {self.incrementMonth()}) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            // View of days in the selected month
            CalendarMonth(selectedDate: self.$selectedDate,
                          dayInMonthDate: firstDayOfMonthDate,
                          shouldHighlightSelection: shouldHighlightSelection)
                .environmentObject(self.userData)
                .frame(height: 170)
        }
    }
}

// MARK: - previews

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(selectedDate: .constant(nil),
                     dayInMonthDate: Date(),
                     shouldHighlightSelection: false)
            .environmentObject(UserData())
    }
}
