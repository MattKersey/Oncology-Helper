//
//  QuestionAppointmentView.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/12/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct QuestionAppointmentView: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @State var showTimes = false
    let appointmentID: Int
    let questionID: Int
    @Binding var audioPlayer: AVPlayer?
    @Binding var playing: IDTimestampSingle?
    
    lazy var questionIndex: Int? = {
        if let index = userData.questions.firstIndex(where: {$0.id == questionID}) {
            return index
        }
        return nil
    }()
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == appointmentID}) {
            return apt
        }
        return nil
    }
    
    var appointmentTimestamps: AppointmentTimestamps? {
        var mutableSelf = self
        guard let qIndex = mutableSelf.questionIndex else {
            return nil
        }
        return userData.questions[qIndex].appointmentTimestamps.first(where: {$0.id == appointmentID})
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: appointment!.date)
    }
    
    // MARK: - functions
    
    func play(appointment: Appointment, timestamp: TimeInterval) -> Void {
        if audioPlayer != nil {
            audioPlayer!.pause()
        }
        audioPlayer = AVPlayer(url: appointment.recordingURL)
        audioPlayer!.seek(to: CMTime(seconds: timestamp, preferredTimescale: 600))
        audioPlayer!.play()
        playing = IDTimestampSingle(id: appointment.id, timestamp: timestamp)
    }
    
    func stop(appointment: Appointment, timestamp: TimeInterval) -> Void {
        guard audioPlayer != nil else {
            return
        }
        audioPlayer!.pause()
        audioPlayer = nil
        playing = nil
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            print("\(appointment!.id): \(appointmentTimestamps!.timestamps[index])")
            userData.deleteTimestamp(appointmentID: appointment!.id,
                                     timestamp: appointmentTimestamps!.timestamps[index])
        }
    }
    
    // MARK: - body
    
    var body: some View {
        var mutableSelf = self
        guard let appointment = self.appointment else {
            return AnyView(Text(""))
        }
        guard mutableSelf.questionIndex != nil else {
            return AnyView(Text(""))
        }
        return AnyView(Group {
            HStack {
                if !appointmentTimestamps!.timestamps.isEmpty {
                    Button(action: {self.showTimes.toggle()}) {
                        Image(systemName: "chevron.right.circle")
                    }
                    .scaleEffect(1.5)
                    .rotationEffect(Angle(degrees: showTimes ? 90.0 : 0.0))
                    .padding(.trailing)
                } else {
                    Button(action: {}) {
                        Image(systemName: "chevron.right.circle")
                            .scaleEffect(1.5)
                            .foregroundColor(Constants.subtitleColor)
                            .padding(.trailing)
                    }
                }
                NavigationLink(destination: AppointmentDetail(id: appointment.id)
                    .environmentObject(self.userData)) {
                        VStack(alignment: .leading) {
                            Text(appointment.doctor)
                                .font(.headline)
                            Text(dateString)
                                .font(.caption)
                        }
                        .foregroundColor(Constants.titleColor)
                        Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            if showTimes {
                ForEach(appointmentTimestamps!.timestamps, id: \.self) { timestamp in
                    HStack {
                        Text(verbatim: String(format: "%.1f", timestamp))
                            .padding(.leading)
                        Spacer()
                        Image(systemName: "doc.text")
                        Divider()
                        if self.playing != nil &&
                            self.playing!.id == appointment.id &&
                            self.playing!.timestamp == timestamp {
                            Button(action: {self.stop(appointment: appointment, timestamp: timestamp)}) {
                                Image(systemName: "stop.fill")
                            }
                        } else {
                            Button(action: {self.play(appointment: appointment, timestamp: timestamp)}) {
                                Image(systemName: "play.fill")
                            }
                        }
                    }
                    .foregroundColor(Constants.bodyColor)
                }
                .onDelete(perform: self.delete)
            }
        })
    }
}

// MARK: - previews

struct QuestionAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAppointmentView(appointmentID: 1,
                                questionID: 1,
                                audioPlayer: .constant(nil),
                                playing: .constant(nil))
            .environmentObject(UserData())
    }
}
