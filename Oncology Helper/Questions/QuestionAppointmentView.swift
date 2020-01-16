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
    let question: Question
    @Binding var audioPlayer: AVPlayer?
    @Binding var playing: DescribedTimestamp?
    @Binding var reload: Bool
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == appointmentID}) {
            return apt
        }
        return nil
    }
    
    var describedTimestamps: [DescribedTimestamp] {
        guard let appointment = self.appointment else {return []}
        return appointment.describedTimestamps.filter({$0.id == question.id})
    }
    
    var dateString: String {
        guard let appointment = self.appointment else {return ""}
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: appointment.date)
    }
    
    // MARK: - functions
    
    func play(appointment: Appointment, timestamp: TimeInterval) -> Void {
        if audioPlayer != nil {
            audioPlayer!.pause()
        }
        audioPlayer = AVPlayer(url: appointment.recordingURL)
        audioPlayer!.seek(to: CMTime(seconds: timestamp, preferredTimescale: 600))
        audioPlayer!.play()
        playing = DescribedTimestamp(id: appointment.id, timestamp: timestamp)
    }
    
    func stop(appointment: Appointment) {
        guard audioPlayer != nil else {
            return
        }
        audioPlayer!.pause()
        audioPlayer = nil
        playing = nil
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            userData.deleteTimestamp(appointmentID: appointment!.id,
                                     timestamp: describedTimestamps[index].timestamp)
        }
    }
    
    // MARK: - body
    
    var body: some View {
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
                    .padding(.trailing)
                } else {
                    Button(action: {}) {
                        Image(systemName: "chevron.right.circle")
                            .scaleEffect(1.5)
                            .foregroundColor(Constants.subtitleColor)
                            .padding(.trailing)
                    }
                }
                NavigationLink(destination: AppointmentDetail(appointment: appointment, reload: self.$reload)
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
                ForEach(describedTimestamps, id: \.self) { describedTimestamp in
                    HStack {
                        Text(verbatim: String(format: "%.1f", describedTimestamp.timestamp))
                            .foregroundColor(Constants.titleColor)
                            .padding(.leading)
                        Spacer()
                        if self.playing != nil &&
                            self.playing!.id == appointment.id &&
                            self.playing!.timestamp == describedTimestamp.timestamp {
                            Button(action: {self.stop(appointment: appointment)}) {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(Constants.itemColor)
                            }
                        } else {
                            Button(action: {self.play(appointment: appointment, timestamp: describedTimestamp.timestamp)}) {
                                Image(systemName: "play.fill")
                                    .foregroundColor(Constants.itemColor)
                            }
                        }
                    }
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
                                question: Question.default,
                                audioPlayer: .constant(nil),
                                playing: .constant(nil),
                                reload: .constant(false))
            .environmentObject(UserData())
    }
}
