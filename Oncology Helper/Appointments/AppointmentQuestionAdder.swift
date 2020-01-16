//
//  AppointmentQuestionAdder.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/15/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentQuestionAdder: View {
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let appointment: Appointment
    @State var newQuestionIDs = Set<Int>()
    let appointmentQuestionIDs: Set<Int>
    
    func addQuestion(question: Question) {
        newQuestionIDs.insert(question.id)
    }
    
    func removeQuestion(question: Question) {
        newQuestionIDs.remove(question.id)
    }
    
    func save() {
        guard let index = userData.appointments.firstIndex(of: appointment) else {
            return
        }
        while !newQuestionIDs.isEmpty {
            userData.appointments[index].questionIDs.append(newQuestionIDs.removeFirst())
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    init(appointment: Appointment) {
        self.appointment = appointment
        var appointmentQuestionIDs = Set<Int>()
        for questionID in appointment.questionIDs {
            appointmentQuestionIDs.insert(questionID)
        }
        self.appointmentQuestionIDs = appointmentQuestionIDs
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(userData.questions) { question in
                    HStack {
                        Text(question.questionString)
                            .foregroundColor(self.appointmentQuestionIDs.contains(question.id) ? Constants.subtitleColor : Constants.titleColor)
                        Spacer()
                        if self.appointmentQuestionIDs.contains(question.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Constants.subtitleColor)
                        } else if self.newQuestionIDs.contains(question.id) {
                            Button(action: {self.removeQuestion(question: question)}) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        } else {
                            Button(action: {self.addQuestion(question: question)}) {
                                Image(systemName: "circle")
                                    .foregroundColor(Constants.titleColor)
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
    }
}

struct AppointmentQuestionAdder_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentQuestionAdder(appointment: Appointment.default)
            .environmentObject(UserData())
    }
}
