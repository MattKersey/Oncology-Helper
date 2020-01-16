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

struct AudioMasterView: View {

    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let appointment: Appointment
    @Binding var audioRecorder: AVAudioRecorder?
    @Binding var audioPlayer: AVPlayer?
    @Binding var currentTime: TimeInterval
    @Binding var isPlaying: Bool
    @State var duration: TimeInterval = 0.0
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
        if userData.appointments[appointmentIndex!].hasRecording && audioRecorder == nil {
            self.reRecordPressed = true
        } else {
            // Check to see if we are beginning a new recording
            if (audioRecorder == nil) {
                audioPlayer = nil
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
        audioPlayer = AVPlayer(url: appointment.recordingURL)
        audioRecorder = nil
    }
    
    func mark(_ timestamp: TimeInterval) {
        userData.addTimestamp(appointmentID: appointment.id, timestamp: timestamp)
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
            HStack {
                if audioRecorder != nil {
                    Button(action: {self.endPressed.toggle()}) {
                        Image(systemName: "stop.fill")
                            .foregroundColor(Constants.warningColor)
                    }
                    .scaleEffect(1.5)
                    .frame(width: 20)
                    Button(action: {self.mark(self.audioRecorder!.currentTime)}) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.25)
                    .padding(.leading)
                } else if appointment.hasRecording {
                    AudioPlaybackView(currentTime: $currentTime,
                                      audioPlayer: $audioPlayer,
                                      isPlaying: $isPlaying,
                                      appointment: appointment)
                        .environmentObject(self.userData)
                } else {
                    Image(systemName: "play.fill")
                        .foregroundColor(Constants.subtitleColor)
                        .scaleEffect(1.5)
                        .frame(width: 20)
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Constants.subtitleColor)
                        .scaleEffect(1.25)
                        .padding([.leading, .trailing])
                }
                
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
                    .frame(width: 20)
                } else {
                    Button(action: {self.pauseRecording()}) {
                        Image(systemName: "pause.fill")
                            .foregroundColor(Constants.warningColor)
                    }
                    .scaleEffect(1.5)
                    .frame(width: 20)
                }
            }
            .padding()
            .buttonStyle(BorderlessButtonStyle())
        })
    }
}

// MARK: - previews

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AudioMasterView(appointment: Appointment.default,
                             audioRecorder: .constant(nil),
                             audioPlayer: .constant(nil),
                             currentTime: .constant(0.0),
                             isPlaying: .constant(false))
            .environmentObject(UserData())
    }
}
