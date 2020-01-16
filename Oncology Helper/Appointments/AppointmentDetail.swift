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
    var id: Int
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == id}) {
            return apt
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    var dateString: String? {
        guard appointment != nil else {return nil}
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: appointment!.date)
    }
    
    init(appointment: Appointment) {
        self.id = appointment.id
        if appointment.hasRecording {
            print("has recording")
            _audioPlayer = State(initialValue: AVPlayer(url: appointment.recordingURL))
        }
    }
    
    // MARK: - body
    
    var body: some View {
        guard let appointment = self.appointment else {
                return AnyView(Text("Appointment unavailable"))
        }
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
                }
            }
            .navigationBarTitle(Text("\(appointment.doctor) | \(self.dateString!)"))
            .navigationBarItems(trailing: Button(action: {self.editMode = true}){Image(systemName: "square.and.pencil")})
            .sheet(isPresented: self.$editMode) {
                AppointmentEditor(appointment: appointment, selectedTime:  appointment.date).environmentObject(self.userData)
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
