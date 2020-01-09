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
    let appointmentId: Int
    @State var isRecording = false
    @State var beganRecording = false
    @State var endPressed = false
    @State var reRecordPressed = false
    @State var playPressed = false
    @State var audioRecorder: AVAudioRecorder? = nil
    
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
    
    func record() -> Void {
        let apt = appointment
        
        // Check to see if we are erasing a file so we can warn the user
        if (apt.hasRecording) {
            self.reRecordPressed = true
        } else {
            // Check to see if we are beginning a new recording
            if (!self.beganRecording) {
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                do {
                    audioRecorder = try AVAudioRecorder(url: apt.recordingURL,
                                                        settings: settings)
                } catch {
                    print("Error initializing recorder")
                    return
                }
                audioRecorder!.prepareToRecord()
                self.beganRecording = true
            }
            self.isRecording = true
            audioRecorder!.record()
        }
    }
    
    func reRecord() -> Void {
        userData.appointments[aptIndex!].hasRecording = false
        userData.appointments[aptIndex!].timestamps = []
        self.reRecordPressed = false
        self.record()
    }
    
    func pause() -> Void {
        self.isRecording = false
        audioRecorder!.pause()
    }
    
    func mark() -> Void {
        userData.appointments[aptIndex!].timestamps.append(audioRecorder!.currentTime)
    }
    
    func end() -> Void {
        self.isRecording = false
        self.beganRecording = false
        self.endPressed = false
        userData.appointments[aptIndex!].hasRecording = true
        audioRecorder!.stop()
        audioRecorder = nil
    }
    
    // MARK: - body
    
    var body: some View {
        HStack {
            // Record/Pause button, check first to see if we are in a warning mode
            if (!self.endPressed && !self.reRecordPressed) {
                if (!self.isRecording) {
                    // If not currently recording, display a record button
                    Button(action: {self.record()}) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.gray)

                            Image(systemName: "circle.fill")
                                .foregroundColor(.red)
                                .scaleEffect(0.35)
                        }
                    }
                    .scaleEffect(2.0)
                } else {
                    // If currently recording, display a pause button
                    Button(action: {self.pause()}) {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    // And a marker button (for marking the time for later)
                    Button(action: {self.mark()}) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    .padding(.leading)
                }
                Spacer()
                // If we have a recording, display the play button
                if (appointment.hasRecording) {
                    Button(action: {self.playPressed.toggle()}) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .scaleEffect(2.0)
                } else if (self.beganRecording) {
                    // If we have started recording, regardless of if we pause, display a stop button
                    Button(action: {self.endPressed.toggle()}) {
                        Image(systemName: "stop.circle.fill")
                            // Make it red if we are currently recording, gray if not
                            .foregroundColor(self.isRecording ? .red : .gray)
                    }
                    .scaleEffect(2.0)
                }
            } else if (self.endPressed) {
                // Warning section for if a user presses stop
                Text("Are you sure you want to end recording?")
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
                Text("Are you sure you want to rerecord? This will delete the previous recording.")
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
        .buttonStyle(BorderlessButtonStyle())
        .sheet(isPresented: self.$playPressed){
            AppointmentRecordingPlay(appointment: self.appointment)
                .environmentObject(self.userData)
        }
    }
}

// MARK: - previews

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording(appointmentId: 0).environmentObject(UserData())
    }
}
