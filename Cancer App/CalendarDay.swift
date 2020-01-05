//
//  CalendarDay.swift
//  Cancer App
//
//  Created by Matt Kersey on 1/5/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarDay: View {
    @EnvironmentObject var userData: UserData
    
    let currentMonthDays: Int
    let previousMonthDays: Int
    let firstDayIndex: Int
    let index: Int
    let ordinal: Int
    let currentDate: Date
    let firstDay: Date
    let currentCalendar: Calendar
    
    var relativeDate_C: Int {
        1 + index + 7 * ordinal - firstDayIndex
    }
    
    var actualDateInt: Int {
        let relativeDate = relativeDate_C
        if (relativeDate <= 0) {
            return previousMonthDays + relativeDate
        } else if (relativeDate > currentMonthDays) {
            return relativeDate - currentMonthDays
        }
        return relativeDate
    }
    
    var inMonth: Bool {
        let relativeDate = relativeDate_C
        if (relativeDate <= 0) || (relativeDate > currentMonthDays) {
            return false
        }
        return true
    }
    
    var actualDate: Date {
        let relativeDate = relativeDate_C
        var month = firstDay
        if (relativeDate <= 0) {
            month = month - TimeInterval(86400)
            month = currentCalendar.date(from: currentCalendar.dateComponents([.year, .month], from: month))!
        } else if (relativeDate > currentMonthDays) {
            month = currentCalendar.date(byAdding: DateComponents(calendar: currentCalendar, month: 1), to: month)!
        }
        return currentCalendar.date(bySetting: .day, value: actualDateInt, of: month)!
    }
    
    var isAppointmentDay: Bool {
        let date = actualDate
        if (userData.appointments.first(where: {currentCalendar.isDate($0.date, inSameDayAs: date)}) != nil) {
            return true
        }
        return false
    }
    
    var body: some View {
        let aptDay = isAppointmentDay
        
        return ZStack {
            if (currentCalendar.isDate(actualDate, inSameDayAs: currentDate)) {
                Image(systemName: "circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(aptDay ? .green : .blue)
                    .opacity(0.5)
            } else if aptDay {
                Image(systemName: "circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(.yellow)
                    .opacity(0.5)
            }
            Text("\(actualDateInt)")
                .font(.footnote)
        }
        .opacity(inMonth ? 1.0 : 0.5)
    }
}

struct CalendarDay_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDay(currentMonthDays: 31, previousMonthDays: 31, firstDayIndex: 4, index: 0, ordinal: 0, currentDate: Date(), firstDay: Date(), currentCalendar: Calendar.current).environmentObject(UserData())
    }
}
