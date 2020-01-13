//
//  HomePage.swift
//  Oncology Helper
//
//  Home page for the Oncology Helper app.
//  Contains an interactive calendar of appointment dates
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct HomePage: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @State var selectedDate: Date? = nil
    @State var selectedQuestion: Question? = nil
    @State var seeAllQuestions: Bool = false
    var todayDate = Date()
    
    // MARK: - body
    
    var body: some View {
        let showModal = Binding<Bool>(get: {
            return self.selectedDate != nil || self.selectedQuestion != nil || self.seeAllQuestions
        }, set: { p in
            self.selectedQuestion = nil
            self.selectedDate = nil
            self.seeAllQuestions = p
        })
        
        return GeometryReader { geo in
            VStack {
                // Calendar of appointments
                Text("Appointments")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .offset(y: 30.0)
                    .frame(width: geo.size.width, height: 120)
                    .background(Constants.backgroundColor)
                    .offset(y: -80.0)
                    .padding(.bottom, -80.0)
                CalendarView(selectedDate: self.$selectedDate,
                             dayInMonthDate: self.todayDate,
                             shouldHighlightSelection: false)
                    .environmentObject(self.userData)
                    .offset(y: -25)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width, height: 250)
                    .padding(.bottom, -45)
                HStack {
                    Spacer()
                    Text("Questions")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(width: geo.size.width, height: 60)
                .background(Constants.backgroundColor)
                .padding(.bottom, -25)
                QuestionPreviewList(selectedQuestion: self.$selectedQuestion, seeAllQuestions: self.$seeAllQuestions)
                    .environmentObject(self.userData)
                Spacer()
            }
            .sheet(isPresented: showModal) {
                // Modal for when a date is selected
                if self.selectedDate != nil {
                    AppointmentList(selectedDate: self.selectedDate!)
                        .environmentObject(self.userData)
                } else if self.selectedQuestion != nil {
                    QuestionDetail(id: self.selectedQuestion!.id)
                        .environmentObject(self.userData)
                } else {
                    Text("Hello World")
                }
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserData())
    }
}
