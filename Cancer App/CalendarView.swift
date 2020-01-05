//
//  CalendarView.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/17/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    var monthYear: Date
    
    let currentCalendar = Calendar.current
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    var ymd: DateComponents{currentCalendar.dateComponents([.year, .month, .day, .weekday, .weekdayOrdinal], from: Date())
    }
    
    var month: String {
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: monthYear)
    }
    
    var year: String {
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: monthYear)
    }
    
    var body: some View {
        VStack() {
            HStack {
                Text(month)
                Spacer()
                Text(year)
            }
            .padding()
            CalendarMonth(day: monthYear)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(monthYear: Date())
    }
}
