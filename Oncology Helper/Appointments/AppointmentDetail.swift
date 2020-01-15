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
    
    // MARK: - body
    
    var body: some View {
        guard let appointment = self.appointment else {
                return AnyView(Text("Appointment unavailable"))
        }
        let showModal = Binding<Bool>(get: {
            return self.playPressed || self.editMode
        }, set: { p in
            self.playPressed = p
            self.editMode = p
        })
        return AnyView(GeometryReader { geo in
            VStack(spacing: 0) {
                AppointmentRecording(appointment: appointment,
                                     audioRecorder: self.$audioRecorder,
                                     playPressed: self.$playPressed)
                    .environmentObject(self.userData)
                    .frame(width: geo.size.width, height: 50.0)
                Divider()
                List {
                    ForEach(appointment.questionIDs, id: \.self) { id in
                        HStack {
                            QuestionMarker(questionID: id, appointmentID: self.id, audioRecorder: self.$audioRecorder)
                                .environmentObject(self.userData)
                        }
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                }
            }
            .navigationBarTitle(Text("\(appointment.doctor) | \(self.dateString!)"))
            .navigationBarItems(trailing: Button(action: {self.editMode = true}){Image(systemName: "square.and.pencil")})
            .sheet(isPresented: showModal){
                if self.playPressed {
                    AppointmentRecordingPlay(appointment: appointment)
                        .environmentObject(self.userData)
                } else {
                    AppointmentEditor(appointment: appointment, selectedTime:  appointment.date).environmentObject(self.userData)
                }
            }
        })
    }
}

// MARK: - previews

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(id: 1).environmentObject(UserData())
    }
}
