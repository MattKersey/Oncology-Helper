//
//  CalendarView.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/17/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var userData: UserData
    @State var selected: Date? = nil
    @State var day: Date
    @State var increment = true
    
    let currentCalendar = Calendar.current
    
    var month: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: day)
    }
    
    var year: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: day)
    }
    
    var firstDay_C: Date {
        let monthComponents = currentCalendar.dateComponents([.year, .month], from: day)
        return currentCalendar.date(from: monthComponents)!
    }
    
    func incrementMonth() -> Void {
        increment = true
        day = currentCalendar.date(byAdding: DateComponents(calendar: currentCalendar, month: 1), to: firstDay_C)!
        day = firstDay_C
    }
    
    func decrementMonth() -> Void {
        increment = false
        day -= TimeInterval(86400)
        day = firstDay_C
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {self.decrementMonth()}) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("\(month) \(year)")
                Spacer()
                Button(action: {self.incrementMonth()}) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            CalendarMonth(selected: self.$selected, day: firstDay_C).environmentObject(self.userData)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(day: Date()).environmentObject(UserData())
    }
}
