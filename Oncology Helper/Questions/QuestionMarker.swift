//
//  QuestionMarker.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/13/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct QuestionMarker: View {
    
    @EnvironmentObject var userData: UserData
    let questionID: Int
    let appointmentID: Int
    @Binding var audioRecorder: AVAudioRecorder?
    @Binding var currentTime: TimeInterval
    
    var question: Question? {
        return userData.questions.first(where: {$0.id == questionID})
    }
    
    var appointment: Appointment? {
        return userData.appointments.first(where: {$0.id == appointmentID})
    }
    
    func mark() {
        let timestamp = audioRecorder != nil ? audioRecorder!.currentTime : currentTime
        userData.addTimestamp(appointmentID: appointmentID,
                              questionID: questionID,
                              timestamp: timestamp)
    }
    
    var body: some View {
        guard let question = self.question else {
            return AnyView(Text(""))
        }
        guard let appointment = self.appointment else {
            return AnyView(Text(""))
        }
        return AnyView(HStack {
            Text(question.questionString)
                .foregroundColor(Constants.titleColor)
            Spacer()
            if (audioRecorder != nil || appointment.hasRecording) {
                Button(action: {self.mark()}) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Constants.itemColor)
                }
                .scaleEffect(1.25)
                .frame(width: 20)
                .padding([.leading])
            } else {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(Constants.subtitleColor)
                    .scaleEffect(1.25)
                    .frame(width: 20)
                    .padding([.leading])
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        )
    }
}

struct QuestionMarker_Previews: PreviewProvider {
    static var previews: some View {
        QuestionMarker(questionID: 1, appointmentID: 1, audioRecorder: .constant(nil), currentTime: .constant(0.0))
            .environmentObject(UserData())
    }
}
