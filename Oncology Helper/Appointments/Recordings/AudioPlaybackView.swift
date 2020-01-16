//
//  AudioMasterView.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/15/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AudioPlaybackView: View {
    @EnvironmentObject var userData: UserData
    @Binding var currentTime: TimeInterval
    @Binding var audioPlayer: AVPlayer?
    @Binding var isPlaying: Bool
    @State var isEditing = false
    let appointment: Appointment
    let duration: TimeInterval
    
    var appointmentIndex: Int? {
        if let index = userData.appointments.firstIndex(where: {$0.id == appointment.id}) {
            return index
        } else {
            return nil
        }
    }
    
    func play() -> Void {
        audioPlayer!.play()
        isPlaying = true
    }
    
    func pause() -> Void {
        audioPlayer!.pause()
        isPlaying = false
    }
    
    func mark(_ timestamp: TimeInterval) -> Void {
        userData.addTimestamp(appointmentID: appointment.id, timestamp: timestamp, sort: true)
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            isEditing = true
            pause()
        } else {
            if audioPlayer == nil {
                audioPlayer = AVPlayer(url: appointment.recordingURL)
            }
            audioPlayer!.seek(to: CMTime(seconds: self.currentTime, preferredTimescale: 600)) { _ in
                self.isEditing = false
                if self.isPlaying {
                    self.play()
                }
            }
        }
    }
    
    init(currentTime: Binding<TimeInterval>, audioPlayer: Binding<AVPlayer?>, isPlaying: Binding<Bool>, appointment: Appointment) {
        _currentTime = currentTime
        _audioPlayer = audioPlayer
        _isPlaying = isPlaying
        self.appointment = appointment
        if _audioPlayer.wrappedValue != nil {
            duration = CMTimeGetSeconds(_audioPlayer.wrappedValue!.currentItem!.asset.duration)
        } else {
            duration = 0.0
        }
    }
    
    var body: some View {
        guard appointmentIndex != nil else {
            return AnyView(Text("Appointment not found"))
        }
        guard audioPlayer != nil else {
            return AnyView(Text("Audio player not initialized"))
        }
        return AnyView(ZStack {
            AudioPlayerView(audioPlayer: $audioPlayer,
                            currentTime: $currentTime,
                            isEditing: $isEditing,
                            isPlaying: $isPlaying)
            HStack {
                if !isPlaying {
                    Button(action: {self.play()}) {
                        Image(systemName: "play.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.5)
                    .frame(width: 20)
                } else {
                    Button(action: {self.pause()}) {
                        Image(systemName: "pause.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.5)
                    .frame(width: 20)
                }
                Button(action: {self.mark(self.currentTime)}) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Constants.itemColor)
                }
                .scaleEffect(1.25)
                .padding([.leading, .trailing])
                Spacer()
                Text("0.0")
                Slider(value: $currentTime, in: 0.0...duration, onEditingChanged: sliderEditingChanged)
                Text(verbatim: String(format: "%.1f", duration))
                    .frame(width: 40)
                    .padding(.trailing)
            }
        }
        .onDisappear(perform: {self.audioPlayer = nil}))
    }
}

// MARK: - UIKit

private class AudioPlayerUIView: UIView {
    private let audioPlayer: Binding<AVPlayer?>
    private let currentTime: Binding<TimeInterval>
    private let isEditing: Binding<Bool>
    private let isPlaying: Binding<Bool>
    private var timeObserverToken: Any?
    private var endObserverToken: Any?
    
    init(audioPlayer: Binding<AVPlayer?>, currentTime: Binding<TimeInterval>, isEditing: Binding<Bool>, isPlaying: Binding<Bool>) {
        self.audioPlayer = audioPlayer
        self.currentTime = currentTime
        self.isEditing = isEditing
        self.isPlaying = isPlaying
        super.init(frame: .zero)
        
        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)
        timeObserverToken = audioPlayer.wrappedValue?.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
            guard let self = self else {return}
            if !self.isEditing.wrappedValue {
                self.currentTime.wrappedValue = time.seconds
            }
            
        }
        endObserverToken = NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didFinishPlaying(note: NSNotification) {
        self.audioPlayer.wrappedValue?.pause()
        self.audioPlayer.wrappedValue?.seek(to: CMTime(seconds: 0.0, preferredTimescale: 600))
        self.isPlaying.wrappedValue = false
    }
    
    func removeObservers() {
        if (timeObserverToken != nil) {
            audioPlayer.wrappedValue?.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
        if (endObserverToken != nil) {
            NotificationCenter.default.removeObserver(endObserverToken!)
            endObserverToken = nil
        }
    }
}

private struct AudioPlayerView: UIViewRepresentable {
    @Binding var audioPlayer: AVPlayer?
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
        audioPlayerUIView.removeObservers()
    }
}

struct AudioPlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlaybackView(currentTime: .constant(0.0), audioPlayer: .constant(nil), isPlaying: .constant(false), appointment: Appointment.default)
        .environmentObject(UserData())
    }
}
