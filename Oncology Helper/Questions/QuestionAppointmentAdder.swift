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
        guard let index = userData.questions.firstIndex(of: question) else {
            return
        }
        while !newAppointmentIds.isEmpty {
            userData.questions[index].appointmentTimestamps.append(AppointmentTimestamps(id: newAppointmentIds.removeFirst(), timestamps: []))
        }
    }
    
    init(question: Question) {
        self.question = question
        var questionAppointmentIds = Set<Int>()
        for appointmentTimestamps in question.appointmentTimestamps {
            questionAppointmentIds.insert(appointmentTimestamps.id)
        }
        self.questionAppointmentIds = questionAppointmentIds
    }
    
    var body: some View {
        VStack {
            CalendarView(selectedDate: $selectedDate, dayInMonthDate: Date(), shouldHighlightSelection: true)
                .environmentObject(self.userData)
            if selectedDate != nil {
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
            Spacer()
            // Done button
            Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        .onDisappear(perform: {self.save()})
    }
}

struct QuestionAppointmentAdder_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAppointmentAdder(question: UserData().questions[0]).environmentObject(UserData())
    }
}
