//
//  AppointmentDetail.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AppointmentDetail: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var editMode = false
    @State var playPressed = false
    @State var audioRecorder: AVAudioRecorder?
    @State var audioPlayer: AVPlayer?
    @State var isPlaying = false
    @State var currentTime: TimeInterval = 0.0
    @State var showTimes = false
    @State var addQuestions = false
    var id: Int
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == id}) {
            return apt
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    var describedTimestamps: [DescribedTimestamp] {
        guard let appointment = self.appointment else {return []}
        return appointment.describedTimestamps.filter({$0.id == nil})
    }
    
    var dateString: String? {
        guard appointment != nil else {return nil}
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: appointment!.date)
    }
    
    func setTime(_ timestamp: TimeInterval) {
        guard audioPlayer != nil else {return}
        audioPlayer!.seek(to: CMTime(seconds: timestamp, preferredTimescale: 600))
        audioPlayer!.play()
        isPlaying = true
    }
    
    func deleteTimestamp(at offsets: IndexSet) {
        for index in offsets {
            userData.deleteTimestamp(appointmentID: appointment!.id,
                                     timestamp: describedTimestamps[index].timestamp)
        }
    }
    
    func deleteQuestion(at offsets: IndexSet) {
        for index in offsets {
            userData.removeQAConnection(appointmentID: appointment!.id, questionID: appointment!.questionIDs[index])
        }
    }
    
    init(appointment: Appointment) {
        self.id = appointment.id
        if appointment.hasRecording {
            _audioPlayer = State(initialValue: AVPlayer(url: appointment.recordingURL))
        }
    }
    
    // MARK: - body
    
    var body: some View {
        guard let appointment = self.appointment else {
                return AnyView(Text("Appointment unavailable"))
        }
        let showModal = Binding<Bool>(get: {
            return self.editMode || self.addQuestions
        }, set: { p in
            self.editMode = p
            self.addQuestions = p
        })
        
        return AnyView(GeometryReader { geo in
            VStack(spacing: 0) {
                AudioMasterView(appointment: appointment,
                                     audioRecorder: self.$audioRecorder,
                                     audioPlayer: self.$audioPlayer,
                                     currentTime: self.$currentTime,
                                     isPlaying: self.$isPlaying)
                    .environmentObject(self.userData)
                    .frame(width: geo.size.width, height: 50.0)
                Divider()
                List {
                    ForEach(appointment.questionIDs, id: \.self) { id in
                        QuestionMarker(questionID: id,
                                       appointmentID: self.id,
                                       audioRecorder: self.$audioRecorder,
                                       audioPlayer: self.$audioPlayer,
                                       currentTime: self.$currentTime,
                                       isPlaying: self.$isPlaying)
                            .environmentObject(self.userData)
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                    .onDelete(perform: self.deleteQuestion)
                    if (!self.describedTimestamps.isEmpty) {
                        Group {
                            HStack{
                                Button(action: {self.showTimes.toggle()}) {
                                    Image(systemName: "chevron.right.circle")
                                }
                                .scaleEffect(1.5)
                                .rotationEffect(Angle(degrees: self.showTimes ? 90.0 : 0.0))
                                Text("Misc")
                                    .foregroundColor(Constants.titleColor)
                                    .padding(.leading)
                                Spacer()
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            if self.showTimes {
                                ForEach(self.describedTimestamps, id: \.self) { describedTimestamp in
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
                                .onDelete(perform: self.deleteTimestamp)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                    Button(action: {self.addQuestions = true}) {
                        Text("Add more questions")
                            .foregroundColor(.blue)
                            .font(.callout)
                    }
                }
            }
            .navigationBarTitle(Text("\(appointment.doctor) | \(self.dateString!)"))
            .navigationBarItems(trailing: Button(action: {self.editMode = true}){Image(systemName: "square.and.pencil")})
            .sheet(isPresented: showModal) {
                if self.editMode {
                    AppointmentEditor(appointment: appointment, selectedTime:  appointment.date).environmentObject(self.userData)
                } else {
                    AppointmentQuestionAdder(appointment: appointment)
                        .environmentObject(self.userData)
                }
            }
        })
    }
}

// MARK: - previews

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(appointment: Appointment.default).environmentObject(UserData())
    }
}
