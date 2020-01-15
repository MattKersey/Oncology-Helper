//
//  QuestionAdder.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/15/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionAdder: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var questionString = ""
    @State var description = ""
    @State var appointmentIDs = Set<Int>()
    @State var selectedDate: Date?
    let userCalendar = Calendar.current
    
    func done() {
        let description = self.description != "" ? self.description : nil
        var aptIDs: [Int] = []
        var id = 0
        for question in userData.questions {
            id = question.id > id ? question.id : id
        }
        id += 1
        while !appointmentIDs.isEmpty {
            let appointmentID = appointmentIDs.removeFirst()
            if let aptIndex = userData.appointments.firstIndex(where: {$0.id == appointmentID}) {
                userData.appointments[aptIndex].questionIDs.append(id)
                aptIDs.append(appointmentID)
            }
        }
        let question = Question(id: id,
                                questionString: questionString,
                                description: description,
                                pin: true,
                                appointmentIDs: aptIDs)
        userData.questions.append(question)
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                // Doctor name field
                VStack(alignment: .leading) {
                    Text("Question")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                        .padding(.top)
                    TextField("Question", text: $questionString)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding([.top, .bottom])
                    Text("Optional Description")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    TextField("Optional Description", text: $description)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding([.top, .bottom])
                    CalendarView(selectedDate: $selectedDate, dayInMonthDate: Date(), shouldHighlightSelection: true)
                        .environmentObject(self.userData)
                        .padding(.bottom)
                }
                if selectedDate != nil {
                    ForEach(self.userData.appointments) { appointment in
                    if self.userCalendar.isDate(appointment.date, inSameDayAs: self.selectedDate!) {
                            HStack {
                                AppointmentRow(appointment: appointment)
                                    .foregroundColor(Constants.titleColor)
                                Spacer()
                                if self.appointmentIDs.contains(appointment.id) {
                                    Button(action: {self.appointmentIDs.remove(appointment.id)}) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                } else {
                                    Button(action: {self.appointmentIDs.insert(appointment.id)}) {
                                        Image(systemName: "circle")
                                            .foregroundColor(Constants.titleColor)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            Spacer()
            if questionString != "" {
                Button(action: {self.done()}) {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(height: 60)
                    .background(Constants.itemColor)
                }
            } else {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 60)
                .background(Constants.subtitleColor)
            }
        }
    }
}

struct QuestionAdder_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAdder()
    }
}
