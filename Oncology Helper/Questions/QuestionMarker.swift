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
    
    var question: Question? {
        return userData.questions.first(where: {$0.id == questionID})
    }
    
    var body: some View {
        guard let question = self.question else {
            return AnyView(Text(""))
        }
        return AnyView(HStack {
            Text(question.questionString)
            Spacer()
            if (audioRecorder != nil) {
                Button(action: {self.userData.addTimestamp(appointmentID: self.appointmentID,
                                                           questionID: self.questionID,
                                                           timestamp: self.audioRecorder!.currentTime)}) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Constants.itemColor)
                }
                .scaleEffect(1.25)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        )
    }
}

struct QuestionMarker_Previews: PreviewProvider {
    static var previews: some View {
        QuestionMarker(questionID: 1, appointmentID: 1, audioRecorder: .constant(nil))
            .environmentObject(UserData())
    }
}
