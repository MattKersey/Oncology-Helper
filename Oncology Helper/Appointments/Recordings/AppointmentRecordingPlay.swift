
//
//  AppointmentRecordingPlay.swift
//  Oncology Helper
//
//  Audio player adapted from:
//  https://medium.com/@chris.mash/avplayer-swiftui-b87af6d0553
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
    @State var audioPlayer: AVPlayer
    @State var currentTime: TimeInterval = 0.0
    @State var isEditing = false
    @State var isPlaying = false
    let appointment: Appointment
    let duration: TimeInterval
    
    var appointmentIndex: Int? {
        if let index = userData.appointments.firstIndex(where: {$0.id == appointment.id}) {
            return index
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    // MARK: - functions
    
    func play() -> Void {
        audioPlayer.play()
        isPlaying = true
    }
    
    func pause() -> Void {
        audioPlayer.pause()
        isPlaying = false
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
        if editingStarted {
            isEditing = true
            pause()
        } else {
            audioPlayer.seek(to: CMTime(seconds: self.currentTime, preferredTimescale: 600)) { _ in
                self.isEditing = false
                if self.isPlaying {
                    self.play()
                }
            }
        }
    }
    
    // MARK: - initializer
    
    init(appointment: Appointment) {
        self.appointment = appointment
        _audioPlayer = State(initialValue: AVPlayer(url: appointment.recordingURL))
        duration = CMTimeGetSeconds(_audioPlayer.wrappedValue.currentItem!.asset.duration)
    }
    
    // MARK: - body
    
    var body: some View {
        guard appointmentIndex != nil else {
            return AnyView(Text("Appointment unavailable"))
        }
        guard duration > 0.0 else {
            return AnyView(Text("Failed to initialize audio player"))
        }
        
        return AnyView(List {
            ZStack {
                AudioPlayerView(audioPlayer: $audioPlayer, currentTime: $currentTime, isEditing: $isEditing, isPlaying: $isPlaying)
                HStack {
                    Button(action: {self.isPlaying ? self.pause() : self.play()}) {
                        Image(systemName: self.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    .padding()
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
                    .padding()
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            Button(action: {print(self.currentTime)}) {
                Text("print cur time")
            }
            ForEach(appointment.timestamps, id: \.self) { timestamp in
                Button(action: {self.setTime(timestamp)}) {
                    Text(verbatim: String(format: "%.1f", timestamp))
                }
            }
            .onDelete(perform: self.delete)
        }
        .onDisappear(perform: pause))
    }
}

// MARK: - UIKit

class AudioPlayerUIView: UIView {
    private let audioPlayer: Binding<AVPlayer>
    private let currentTime: Binding<TimeInterval>
    private let isEditing: Binding<Bool>
    private let isPlaying: Binding<Bool>
    private var timeObserverToken: Any?
    
    init(audioPlayer: Binding<AVPlayer>, currentTime: Binding<TimeInterval>, isEditing: Binding<Bool>, isPlaying: Binding<Bool>) {
        self.audioPlayer = audioPlayer
        self.currentTime = currentTime
        self.isEditing = isEditing
        self.isPlaying = isPlaying
        super.init(frame: .zero)
        
        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)
        timeObserverToken = audioPlayer.wrappedValue.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
            guard let self = self else {return}
            if !self.isEditing.wrappedValue {
                self.currentTime.wrappedValue = time.seconds
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didFinishPlaying(note: NSNotification) {
        self.audioPlayer.wrappedValue.pause()
        self.audioPlayer.wrappedValue.seek(to: CMTime(seconds: 0.0, preferredTimescale: 600))
        self.isPlaying.wrappedValue = false
    }
    
    func removePeriodicTimeObserver() {
        if (timeObserverToken != nil) {
            audioPlayer.wrappedValue.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
    }
}

struct AudioPlayerView: UIViewRepresentable {
    @Binding var audioPlayer: AVPlayer
    @Binding var currentTime: TimeInterval
    @Binding var isEditing: Bool
    @Binding var isPlaying: Bool
    
    func makeUIView(context: UIViewRepresentableContext<AudioPlayerView>) -> UIView {
        let uiView = AudioPlayerUIView(audioPlayer: $audioPlayer, currentTime: $currentTime, isEditing: $isEditing, isPlaying: $isPlaying)
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AudioPlayerView>) {
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let audioPlayerUIView = uiView as? AudioPlayerUIView else {
            return
        }
        audioPlayerUIView.removePeriodicTimeObserver()
    }
}

// MARK: - previews

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(appointment: appointmentData[0])
            .environmentObject(UserData())
    }
}
