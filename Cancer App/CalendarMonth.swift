//
//  CalendarMonth.swift
//  Cancer App
//
//  Created by Matt Kersey on 1/5/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarMonth: View {
    var day: Date
    
    var weekDays: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    let currentCalendar = Calendar.current
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "dd"
        return formatter
    }
    
    var firstDay_C: Date {
        let monthComponents = currentCalendar.dateComponents([.year, .month], from: day)
        return currentCalendar.date(from: monthComponents)!
    }
    
    var currentMonthDays_C: Int {
        let firstDayNextMonth = currentCalendar.date(byAdding: DateComponents(calendar: currentCalendar, month: 1), to: firstDay_C)!
        let finalDay = firstDayNextMonth - TimeInterval(86400)
        return Int(dateFormatter.string(from: finalDay))!
    }
    
    var previousMonthDays_C: Int {
        let finalDay = firstDay_C - TimeInterval(86400)
        return Int(dateFormatter.string(from: finalDay))!
    }
    
    var firstDayIndex_C: Int {
        let dayIndex = currentCalendar.component(.weekday, from: firstDay_C)
        return dayIndex - 1
    }
    
    var body: some View {
        let currentMonthDays = currentMonthDays_C
        let previousMonthDays = previousMonthDays_C
        let firstDayIndex = firstDayIndex_C
        let numWeeks = Int(ceil(Double((firstDayIndex + currentMonthDays)) / 7.0))
        var relativeDate = 0
        
        return HStack(alignment: .top, spacing: 10) {
            ForEach(self.weekDays.indices) { index in
                VStack {
                    Text(self.weekDays[index])
                        .font(.subheadline)
                    ForEach(0 ..< numWeeks) { ordinal in
//                        if (index + 7 * ordinal - firstDayIndex < 0) {
//                            Text("\(previousMonthDays + 1 + index + 7 * ordinal - firstDayIndex)")
//                            .font(.footnote)
//                        } else if (1 + index + 7 * ordinal - firstDayIndex > currentMonthDays) {
//                            Text("\(1 + index + 7 * ordinal - firstDayIndex - currentMonthDays)")
//                            .font(.footnote)
//                        } else {
//                            Text("\(1 + index + 7 * ordinal - firstDayIndex)")
//                            .font(.footnote)
//                        }
                        ZStack {
                            Image(systemName: "circle.fill")
                                .imageScale(.medium)
                                .foregroundColor(.blue)
                                .opacity(0.5)
                            Text("\(1 + index + 7 * ordinal - firstDayIndex)")
                                .font(.footnote)
                        }
                    }
                }
                if (index < self.weekDays.count - 1) {
                    Divider()
                }
            }
        }
    }
}

struct CalendarMonth_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMonth(day: Date())
    }
}
