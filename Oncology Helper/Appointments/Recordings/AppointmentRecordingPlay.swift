
//
//  AppointmentRecordingPlay.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/18/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AppointmentRecordingPlay: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let appointment: Appointment
    @State var audioPlayer: AVAudioPlayer?
    
    var appointmentIndex: Int? {
        if let index = userData.appointments.firstIndex(where: {$0.id == appointment.id}) {
            return index
        } else {
            print("index of appointment is nil")
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    // MARK: - functions
    
    func play() -> Void {
        audioPlayer!.play()
    }
    
    func setTime(_ timestamp: TimeInterval) {
        audioPlayer!.currentTime = timestamp
    }
    
    func mark() -> Void {
        if let aptIndex = appointmentIndex {
            var index = 0
            for timestamp in appointment.timestamps {
                if timestamp > audioPlayer!.currentTime {
                    break
                }
                index += 1
            }
            userData.appointments[aptIndex].timestamps.insert(audioPlayer!.currentTime, at: index)
        }
    }
    
    func delete(at offsets: IndexSet) {
        if let aptIndex = appointmentIndex {
            userData.appointments[aptIndex].timestamps.remove(atOffsets: offsets)
        }
    }
    
    // MARK: - init
    
    init(appointment: Appointment) {
        self.appointment = appointment
        do {
            try _audioPlayer = State(initialValue: AVAudioPlayer(contentsOf: appointment.recordingURL))
        } catch {
            print("audioPlayer was not initialized")
        }
    }
    
    // MARK: - body
    
    var body: some View {
        let currentTime = Binding<TimeInterval>(get: {
            if self.audioPlayer != nil {
                return self.audioPlayer!.currentTime
            }
            return -1.0
        }, set: { p in
            if (self.audioPlayer != nil) {
                self.audioPlayer!.currentTime = p
            }
        })
        
        return List {
            if audioPlayer != nil && appointmentIndex != nil  {
                HStack {
                    Button(action: {self.play()}) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    Spacer()
                    Slider(value: currentTime, in: 0.0...audioPlayer!.duration, step: 0.01)
                    Spacer()
                    Button(action: {self.mark()}) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                }
                .buttonStyle(BorderlessButtonStyle())
                ForEach(appointment.timestamps, id: \.self) { timestamp in
                    Button(action: {self.setTime(timestamp)}) {
                        Text("\(timestamp)")
                    }
                }
                .onDelete(perform: self.delete)
            } else if audioPlayer == nil {
                Text("Failed to initialize audio player")
            } else {
                Text("Could not find appointment")
            }
        }
    }
}

// MARK: - previews

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(appointment: appointmentData[0])
            .environmentObject(UserData())
    }
}
