
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
    let appointmentId: Int
    @State var audioPlayer: AVAudioPlayer? = nil
    
    var aptIndex: Int? {
        if let index = userData.appointments.firstIndex(where: {$0.id == appointmentId}) {
            return index
        } else {
            print("index of appointment is nil")
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    var appointment: Appointment {
        userData.appointments[aptIndex!]
    }
    
    // MARK: - functions
    
    func play() -> Void {
        if (audioPlayer == nil) {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: appointment.recordingURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("audioPlayer was not initialized")
                return
            }
        }
        audioPlayer!.play()
    }
    
    func setTime(_ timestamp: TimeInterval) {
        if (audioPlayer == nil) {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: appointment.recordingURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("audioPlayer was not initialized")
                return
            }
        }
        audioPlayer!.currentTime = timestamp
    }
    
    func mark() -> Void {
        var index = 0
        for timestamp in appointment.timestamps {
            if timestamp > audioPlayer!.currentTime {
                break
            }
            index += 1
        }
        userData.appointments[aptIndex!].timestamps.insert(audioPlayer!.currentTime, at: index)
    }
    
    func delete(at offsets: IndexSet) {
        userData.appointments[aptIndex!].timestamps.remove(atOffsets: offsets)
    }
    
    // MARK: - body
    
    var body: some View {
        let apt = appointment
        return List {
            HStack {
                Button(action: {self.play()}) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.red)
                }
                .scaleEffect(2.0)
                Spacer()
                if (audioPlayer != nil) {
                    // Slider(value: audioPlayer!.currentTime, in: 0.0...audioPlayer!.duration, step: 0.01)
                }
                Spacer()
                Button(action: {self.mark()}) {
                    Image(systemName: "flag.circle.fill")
                        .foregroundColor(.red)
                }
                .scaleEffect(2.0)
            }
            .buttonStyle(BorderlessButtonStyle())
            ForEach(apt.timestamps, id: \.self) { timestamp in
                Button(action: {self.setTime(timestamp)}) {
                    Text("\(timestamp)")
                }
            }
            .onDelete(perform: self.delete)
        }
    }
}

// MARK: - previews

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(appointmentId: 0)
            .environmentObject(UserData())
    }
}
