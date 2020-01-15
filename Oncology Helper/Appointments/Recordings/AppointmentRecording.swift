//
//  AppointmentRecording.swift
//  Oncology Helper
//
//  View for controlling audio recording
//
//  Code for audio recording adapted from
//  https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
//
//  Created by Matt Kersey on 12/17/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AppointmentRecording: View {

    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let appointment: Appointment
    @Binding var audioRecorder: AVAudioRecorder?
    @Binding var audioPlayer: AVPlayer?
    @State var currentTime: TimeInterval = 0.0
    @State var duration: TimeInterval = 0.0
    @State var isEditing = false
    @State var isPlaying = false
    @State var isRecording = false
    @State var endPressed = false
    @State var reRecordPressed = false
    
    var appointmentIndex: Int? {
        if let index = userData.appointments.firstIndex(where: {$0.id == appointment.id}) {
            return index
        } else {
            print("index of appointment is nil")
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    // MARK: - recorder functions
    
    func record() -> Void {
        // Check to see if we are erasing a file so we can warn the user
        if (userData.appointments[appointmentIndex!].hasRecording) {
            self.reRecordPressed = true
        } else {
            audioPlayer = nil
            // Check to see if we are beginning a new recording
            if (audioRecorder == nil) {
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                do {
                    audioRecorder = try AVAudioRecorder(url: appointment.recordingURL, settings: settings)
                } catch {
                    print("audioRecorder was not initialized")
                    return
                }
            }
            self.isRecording = true
            audioRecorder!.record()
        }
    }
    
    func reRecord() {
        userData.appointments[appointmentIndex!].describedTimestamps = []
        do {
            try FileManager.default.removeItem(at: userData.appointments[appointmentIndex!].recordingURL)
        } catch {}
        self.reRecordPressed = false
        self.record()
    }
    
    func pauseRecording() {
        self.isRecording = false
        audioRecorder!.pause()
    }
    
    func endRecording() {
        self.isRecording = false
        self.endPressed = false
        audioRecorder!.stop()
        audioRecorder = nil
    }
    
    // MARK: - player functions
    
    func play() {
        if audioPlayer == nil {
            audioPlayer = AVPlayer(url: appointment.recordingURL)
            duration = CMTimeGetSeconds(audioPlayer!.currentItem!.asset.duration)
        }
        audioPlayer!.play()
        isPlaying = true
    }
    
    func pausePlayback() {
        
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        guard audioPlayer != nil else {return}
        if editingStarted {
            isEditing = true
            pauseRecording()
        } else {
            audioPlayer!.seek(to: CMTime(seconds: self.currentTime, preferredTimescale: 600)) { _ in
                self.isEditing = false
                if self.isPlaying {
                    self.play()
                }
            }
        }
    }
    
    // MARK: - shared functions
    
    func mark(_ timestamp: TimeInterval) {
        userData.addTimestamp(appointmentID: appointment.id, timestamp: timestamp)
    }
    
    // MARK: - initializer
    
    init(appointment: Appointment,
         audioRecorder: Binding<AVAudioRecorder?>,
         audioPlayer: Binding<AVPlayer?>) {
        self.appointment = appointment
        _audioRecorder = audioRecorder
        _audioPlayer = audioPlayer
    }
    
    // MARK: - body
    
    var body: some View {
        
        // MARK: - guards
        
        guard userData.audioSession != nil else {
            return AnyView(Text("Permission to record denied"))
        }
        guard self.appointmentIndex != nil else {
            return AnyView(Text("Could not find appointment"))
        }
        guard !self.endPressed else {
            return AnyView(HStack(spacing: 0) {
                Text("End recording?")
                    .font(.headline)
                    .foregroundColor(Constants.warningColor)
                    .padding()
                Spacer()
                Divider()
                Button(action: {self.endRecording()}) {
                    Text("Yes")
                        .foregroundColor(Constants.warningColor)
                        .padding()
                }
                Button(action: {self.endPressed.toggle()}) {
                    Text("No")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(height: 50)
                        .background(Constants.itemColor)
                }
            })
        }
        guard !self.reRecordPressed else {
            return AnyView(HStack(spacing: 0) {
                Text("Delete previous recording?")
                    .font(.headline)
                    .foregroundColor(Constants.warningColor)
                    .padding()
                Spacer()
                Divider()
                Button(action: {self.reRecord()}) {
                    Text("Yes")
                        .foregroundColor(Constants.warningColor)
                        .padding()
                }
                Button(action: {self.reRecordPressed.toggle()}) {
                    Text("No")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(height: 50)
                        .background(Constants.itemColor)
                }
            })
        }
        
        // MARK: - main view
        
        return AnyView(ZStack {
            AudioPlayerView(audioPlayer: $audioPlayer,
                            currentTime: $currentTime,
                            isEditing: $isEditing,
                            isPlaying: $isPlaying)
            HStack {
                if audioRecorder != nil {
                    Button(action: {self.endPressed.toggle()}) {
                        Image(systemName: "stop.fill")
                            .foregroundColor(Constants.warningColor)
                    }
                    .scaleEffect(1.5)
                    Button(action: {self.mark(self.audioRecorder!.currentTime)}) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.25)
                    .padding(.leading)
                } else if appointment.hasRecording {
                    if !isPlaying {
                        Button(action: {self.play()}) {
                            Image(systemName: "play.fill")
                                .foregroundColor(Constants.itemColor)
                        }
                        .scaleEffect(1.5)
                    } else {
                        Button(action: {self.pausePlayback()}) {
                            Image(systemName: "pause.fill")
                                .foregroundColor(Constants.itemColor)
                        }
                        .scaleEffect(1.5)
                    }
                    Button(action: {self.mark(self.currentTime)}) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.25)
                    .padding(.leading)
                } else {
                    Image(systemName: "play.fill")
                        .foregroundColor(Constants.subtitleColor)
                        .scaleEffect(1.5)
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Constants.subtitleColor)
                        .scaleEffect(1.25)
                        .padding(.leading)
                }
//                Spacer()
//                Text("0")
                Slider(value: $currentTime, in: 0.0...duration, onEditingChanged: sliderEditingChanged)
                    
//                Text(verbatim: String(format: "%.1f", self.duration))
                Spacer()
                if !self.isRecording {

                    Button(action: {self.record()}) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Constants.subtitleColor)

                            Image(systemName: "circle.fill")
                                .foregroundColor(Constants.warningColor)
                                .scaleEffect(0.35)
                        }
                    }
                    .scaleEffect(2.0)
                } else {
                    Button(action: {self.pauseRecording()}) {
                        Image(systemName: "pause.fill")
                            .foregroundColor(Constants.warningColor)
                    }
                    .scaleEffect(1.5)
                }
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
        })
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
        print("init")
        if audioPlayer.wrappedValue != nil {
            print("good")
        } else {
            print("bad")
        }
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
            if audioPlayer.wrappedValue != nil {
                audioPlayer.wrappedValue!.removeTimeObserver(timeObserverToken!)
                timeObserverToken = nil
            }
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

// MARK: - previews

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording(appointment: UserData().appointments[0],
                             audioRecorder: .constant(nil),
                             audioPlayer: .constant(nil)).environmentObject(UserData())
    }
}
