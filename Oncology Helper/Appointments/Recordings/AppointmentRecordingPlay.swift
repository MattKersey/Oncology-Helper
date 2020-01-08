
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
/**************************************** Variables ********************************************/
    
    var appointment: Appointment
    
    @State var audioPlayer: AVAudioPlayer? = nil
    
/**************************************** Functions ********************************************/
    
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
    
    var body: some View {
        List {
            HStack {
                Button(action: {self.play()}) {
                    Image(systemName: "play.circle.fill")
                }
//                Slider(value: audioPlayer!.currentTime, in: 0.0...audioPlayer!.duration, step: 0.01)
            }
            ForEach(appointment.timestamps, id: \.self) { timestamp in
                Button(action: {self.setTime(timestamp)}) {
                    Text("\(timestamp)")
                }
            }
        }
    }
}

/**************************************** Preview ********************************************/

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(appointment: UserData().appointments[0])
    }
}
