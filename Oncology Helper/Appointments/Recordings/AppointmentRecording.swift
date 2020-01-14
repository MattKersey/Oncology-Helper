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
    @State var audioRecorder: AVAudioRecorder?
    
    @State var isRecording = false
    @State var beganRecording = false
    @State var endPressed = false
    @State var reRecordPressed = false
    @Binding var playPressed: Bool
    
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
    
    func record() -> Void {
        // Check to see if we are erasing a file so we can warn the user
        if (userData.appointments[appointmentIndex!].hasRecording) {
            self.reRecordPressed = true
        } else {
            // Check to see if we are beginning a new recording
            if (!self.beganRecording) {
                self.beganRecording = true
            }
            self.isRecording = true
            audioRecorder!.record()
        }
    }
    
    func reRecord() -> Void {
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
            self.reRecordPressed = false
            return
        }
        userData.appointments[appointmentIndex!].hasRecording = false
        userData.appointments[appointmentIndex!].describedTimestamps = []
        for id in userData.appointments[appointmentIndex!].questionIDs {
            if let index = userData.questions.firstIndex(where: {$0.id == id}) {
                userData.questions[index].appointmentTimestamps.removeAll(where: {$0.id == appointment.id})
            }
        }
        self.reRecordPressed = false
        self.record()
    }
    
    func pause() -> Void {
        self.isRecording = false
        audioRecorder!.pause()
    }
    
    func mark() -> Void {
        userData.addTimestamp(appointmentID: appointment.id, timestamp: audioRecorder!.currentTime)
    }
    
    func end() -> Void {
        self.isRecording = false
        self.beganRecording = false
        self.endPressed = false
        userData.appointments[appointmentIndex!].hasRecording = true
        audioRecorder!.stop()
        audioRecorder = nil
    }
    
    // MARK: - initializer
    
    init(appointment: Appointment, playPressed: Binding<Bool>) {
        self.appointment = appointment
        _playPressed = playPressed
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            _audioRecorder = try State(initialValue: AVAudioRecorder(url: appointment.recordingURL, settings: settings))
        } catch {
            print("audioRecorder was not initialized")
        }
    }
    
    // MARK: - body
    
    var body: some View {
        guard userData.audioSession != nil else {
            return AnyView(Text("Permission to record denied"))
        }
        guard let appointmentIndex = self.appointmentIndex else {
            return AnyView(Text("Could not find appointment"))
        }
        guard audioRecorder != nil || userData.appointments[appointmentIndex].hasRecording else {
            return AnyView(Text("Failed to initialize audio recorder"))
        }
        return AnyView(HStack {
            // Record/Pause button, check first to see if we are in a warning mode
            if !self.endPressed && !self.reRecordPressed {
                if !self.isRecording {
                    // If not currently recording, display a record button
                    Button(action: {self.record()}) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Constants.subtitleColor)

                            Image(systemName: "circle.fill")
                                .foregroundColor(.red)
                                .scaleEffect(0.35)
                        }
                    }
                    .scaleEffect(2.0)
                } else {
                    // If currently recording, display a pause button
                    Button(action: {self.pause()}) {
                        Image(systemName: "pause.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.5)
                    // And a marker button (for marking the time for later)
                    Button(action: {self.mark()}) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.25)
                    .padding(.leading)
                }
                Spacer()
                // If we have a recording, display the play button
                if appointment.hasRecording {
                    Button(action: {self.playPressed.toggle()}) {
                        Image(systemName: "play.fill")
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.5)
                } else if self.beganRecording {
                    // If we have started recording, regardless of if we pause, display a stop button
                    Button(action: {self.endPressed.toggle()}) {
                        Image(systemName: "stop.fill")
                            // Make it red if we are currently recording, gray if not
                            .foregroundColor(Constants.itemColor)
                    }
                    .scaleEffect(1.5)
                }
            } else if self.endPressed {
                // Warning section for if a user presses stop
                Text("End recording?")
                    .foregroundColor(.red)
                Spacer()
                Button(action: {self.endPressed.toggle()}) {
                    Text("No")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                Divider()
                Button(action: {self.end()}) {
                    Text("Yes")
                        .foregroundColor(.red)
                }
            } else {
                // Warning section for if a user presses record on an appointment that alreay has a recording
                Text("Delete previous recording.")
                    .foregroundColor(.red)
                Spacer()
                Button(action: {self.reRecordPressed.toggle()}) {
                    Text("No")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                Divider()
                Button(action: {self.reRecord()}) {
                    Text("Yes")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle()))
    }
}

// MARK: - previews

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording(appointment: UserData().appointments[0], playPressed: .constant(false)).environmentObject(UserData())
    }
}
