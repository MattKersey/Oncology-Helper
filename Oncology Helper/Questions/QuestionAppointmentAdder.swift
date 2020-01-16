//
//  QuestionAppointmentAdder.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/13/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionAppointmentAdder: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var selectedDate: Date? = nil
    let userCalendar = Calendar.current
    let question: Question
    @State var newAppointmentIds = Set<Int>()
    let questionAppointmentIds: Set<Int>
    
    func addAppointment(appointment: Appointment) -> Void {
        newAppointmentIds.insert(appointment.id)
    }
    
    func removeAppointment(appointment: Appointment) -> Void {
        newAppointmentIds.remove(appointment.id)
    }
    
    func save() -> Void {
        while !newAppointmentIds.isEmpty {
            let newAppointmentID = newAppointmentIds.removeFirst()
            if let aptIndex = userData.appointments.firstIndex(where: {$0.id == newAppointmentID}) {
                question.appointmentIDs.append(newAppointmentID)
                userData.appointments[aptIndex].questionIDs.append(question.id)
            }
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    init(question: Question) {
        self.question = question
        var questionAppointmentIds = Set<Int>()
        for appointmentID in question.appointmentIDs {
            questionAppointmentIds.insert(appointmentID)
        }
        self.questionAppointmentIds = questionAppointmentIds
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(selectedDate: $selectedDate, dayInMonthDate: Date(), shouldHighlightSelection: true)
                .environmentObject(self.userData)
            Divider()
                .padding(.top)
            if selectedDate != nil {
                Group {
                    List {
                        ForEach(self.userData.appointments) { appointment in
                            if self.userCalendar.isDate(appointment.date, inSameDayAs: self.selectedDate!) {
                                HStack {
                                    AppointmentRow(appointment: appointment)
                                        .foregroundColor(self.questionAppointmentIds.contains(appointment.id) ? Constants.subtitleColor : Constants.titleColor)
                                    Spacer()
                                    if self.questionAppointmentIds.contains(appointment.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Constants.subtitleColor)
                                    } else if self.newAppointmentIds.contains(appointment.id) {
                                        Button(action: {self.removeAppointment(appointment: appointment)}) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    } else {
                                        Button(action: {self.addAppointment(appointment: appointment)}) {
                                            Image(systemName: "circle")
                                                .foregroundColor(Constants.titleColor)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Spacer()
            // Done button
            Button(action: {self.save()}) {
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
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

struct QuestionAppointmentAdder_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAppointmentAdder(question: Question.default).environmentObject(UserData())
    }
}
