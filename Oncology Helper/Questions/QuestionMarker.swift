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
    @Binding var audioPlayer: AVPlayer?
    @Binding var currentTime: TimeInterval
    @Binding var isPlaying: Bool
    @State var showTimes = false
    
    var question: Question? {
        return userData.questions.first(where: {$0.id == questionID})
    }
    
    var appointment: Appointment? {
        return userData.appointments.first(where: {$0.id == appointmentID})
    }
    
    var describedTimestamps: [DescribedTimestamp] {
        guard let appointment = self.appointment else {return []}
        return appointment.describedTimestamps.filter({$0.id == questionID})
    }
    
    func mark() {
        let timestamp = audioRecorder != nil ? audioRecorder!.currentTime : currentTime
        userData.addTimestamp(appointmentID: appointmentID,
                              questionID: questionID,
                              timestamp: timestamp)
    }
    
    func setTime(_ timestamp: TimeInterval) {
        guard audioPlayer != nil else {return}
        audioPlayer!.seek(to: CMTime(seconds: timestamp, preferredTimescale: 600))
        audioPlayer!.play()
        isPlaying = true
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            userData.deleteTimestamp(appointmentID: appointment!.id,
                                     timestamp: describedTimestamps[index].timestamp)
        }
    }
    
    var body: some View {
        guard let question = self.question else {
            return AnyView(Text(""))
        }
        guard let appointment = self.appointment else {
            return AnyView(Text(""))
        }
        return AnyView(Group {
            HStack {
                if !describedTimestamps.isEmpty {
                    Button(action: {self.showTimes.toggle()}) {
                        Image(systemName: "chevron.right.circle")
                    }
                    .scaleEffect(1.5)
                    .rotationEffect(Angle(degrees: showTimes ? 90.0 : 0.0))
                } else {
                    Button(action: {}) {
                        Image(systemName: "chevron.right.circle")
                            .scaleEffect(1.5)
                            .foregroundColor(Constants.subtitleColor)
                    }
                }
                Text(question.questionString)
                    .foregroundColor(Constants.titleColor)
                    .padding(.leading)
                Spacer()
                if (audioRecorder != nil || appointment.hasRecording) {
                    Button(action: {self.mark()}) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.25)
                    .frame(width: 20)
                    .padding(.leading)
                } else {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Constants.subtitleColor)
                        .scaleEffect(1.25)
                        .frame(width: 20)
                        .padding(.leading)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            if showTimes {
                ForEach(describedTimestamps, id: \.self) { describedTimestamp in
                    HStack {
                        Text(verbatim: String(format: "%.1f", describedTimestamp.timestamp))
                            .padding(.leading)
                            .foregroundColor(Constants.titleColor)
                        Spacer()
                        if (self.audioPlayer != nil) {
                            Button(action: {self.setTime(describedTimestamp.timestamp)}) {
                                Image(systemName: "play.fill")
                                    .foregroundColor(Constants.itemColor)
                            }
                        } else {
                            Button(action: {}) {
                                Image(systemName: "play.fill")
                                    .foregroundColor(Constants.subtitleColor)
                            }
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .onDelete(perform: self.delete)
            }
        })
    }
}

struct QuestionMarker_Previews: PreviewProvider {
    static var previews: some View {
        QuestionMarker(questionID: 1,
                       appointmentID: 1,
                       audioRecorder: .constant(nil),
                       audioPlayer: .constant(nil),
                       currentTime: .constant(0.0),
                       isPlaying: .constant(false))
            .environmentObject(UserData())
    }
}
