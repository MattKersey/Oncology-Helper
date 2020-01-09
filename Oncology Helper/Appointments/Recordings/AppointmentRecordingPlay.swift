
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
    @State var audioPlayer: AVPlayer
    @State private(set) var currentTime: TimeInterval = 0.0
    let duration: TimeInterval
    
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
        audioPlayer.play()
    }
    
    func setTime(_ timestamp: TimeInterval) {
        audioPlayer.seek(to: CMTime(seconds: timestamp, preferredTimescale: 600))
        audioPlayer.play()
    }
    
    func mark(_ timestamp: TimeInterval) -> Void {
        var index = 0
        for storedTimestamp in userData.appointments[appointmentIndex!].timestamps {
            if storedTimestamp > timestamp {
                break
            }
            index += 1
        }
        userData.appointments[appointmentIndex!].timestamps.insert(timestamp, at: index)
    }
    
    func delete(at offsets: IndexSet) {
        userData.appointments[appointmentIndex!].timestamps.remove(atOffsets: offsets)
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        audioPlayer.seek(to: CMTime(seconds: self.currentTime, preferredTimescale: 600))
    }
    
    // MARK: - init
    
    init(appointment: Appointment) {
        self.appointment = appointment
        _audioPlayer = State(initialValue: AVPlayer(url: appointment.recordingURL))
        duration = CMTimeGetSeconds(_audioPlayer.wrappedValue.currentItem!.asset.duration)
    }
    
    // MARK: - body
    
    var body: some View {
        return List {
            if duration > 0.0 && appointmentIndex != nil  {
                AudioPlayerView(audioPlayer: $audioPlayer, currentTime: $currentTime)
                HStack {
                    Button(action: {self.play()}) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    Spacer()
                    Text("0")
                    Slider(value: $currentTime, in: 0.0...duration, onEditingChanged: sliderEditingChanged)
                    Text(verbatim: String(format: "%.1f", duration))
                    Spacer()
                    Button(action: {self.mark(CMTimeGetSeconds(self.audioPlayer.currentTime()))}) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                }
                .buttonStyle(BorderlessButtonStyle())
                Button(action: {print(self.currentTime)}) {
                    Text("print cur time")
                }
                ForEach(appointment.timestamps, id: \.self) { timestamp in
                    Button(action: {self.setTime(timestamp)}) {
                        Text(verbatim: String(format: "%.1f", timestamp))
                    }
                }
                .onDelete(perform: self.delete)
            } else if appointmentIndex == nil {
                Text("Could not find appointment")
            } else {
                Text("Failed to initialize audio player")
            }
        }
    }
}

// MARK: - UIKit

class AudioPlayerUIView: UIView {
    private let audioPlayer: Binding<AVPlayer>
    private let currentTime: Binding<TimeInterval>
    private var timeObservation: Any?
    
    init(audioPlayer: Binding<AVPlayer>, currentTime: Binding<TimeInterval>) {
        self.audioPlayer = audioPlayer
        self.currentTime = currentTime
        super.init(frame: .null)
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObservation = audioPlayer.wrappedValue.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
            guard let self = self else {return}
 
            self.currentTime.wrappedValue = time.seconds
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct AudioPlayerView: UIViewRepresentable {
    @Binding var audioPlayer: AVPlayer
    @Binding private(set) var currentTime: TimeInterval
    
    func makeUIView(context: UIViewRepresentableContext<AudioPlayerView>) -> UIView {
        let uiView = AudioPlayerUIView(audioPlayer: $audioPlayer, currentTime: $currentTime)
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AudioPlayerView>) {
    }
}

// MARK: - previews

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(appointment: appointmentData[0])
            .environmentObject(UserData())
    }
}
