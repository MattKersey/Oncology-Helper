//
//  AppointmentRecording.swift
//  Oncology Helper
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
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData   // For accessing JSON file
    var id: Int                                 // For indexing in userData
    
    @State var testBool = false                 // For texting, equivalent to audioRecorder.isRecording
                                                    // TODO: Replace with audioRecorder.isRecording
    @State var beganRecording = false           // If this session has been started
    @State var endPressed = false               // If stop has been pressed (for warning)

    @State var reRecordPressed = false          // If record has been pressed with recording in memory
    @State var playPressed = false              // If the play button has been pressed
    
    var aptIndex: Int? {                        // Index variable for appointment in the array
        if let index = userData.appointments.firstIndex(where: {$0.id == id}) {
            return index
        } else {
            print("index is nil")
            return nil
        }
    }
    
    var audioRecorder: AVAudioRecorder? {       // Audio recorder object
        // Settings for the recorder
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        var recorder: AVAudioRecorder? = nil
        // Attempt to initialize the recorder
        do {
            recorder = try AVAudioRecorder(url: userData.appointments[aptIndex!].recordingURL, settings: settings)
        } catch {
            // If there is an error, print message and return nil
            print("Error initializing recorder")
            return nil
        }
        return recorder
    }
    
/**************************************** Functions ********************************************/
    
    /*
     Function for starting or resuming a recording
     */
    func record() -> Void {
        // Check to see if we are erasing a file so we can warn the user
        if (userData.appointments[aptIndex!].hasRecording) {
            self.reRecordPressed = true
        } else {
            // Check to see if we are beginning a new recording
            if (!self.beganRecording) {
                // Initialize audio file
                audioRecorder!.prepareToRecord()
                self.beganRecording = true
            }
            self.testBool = true
            audioRecorder!.record()
        }
    }
    
    /*
     Function for recording a new session over one that already exists
     */
    func reRecord() -> Void {
        userData.appointments[aptIndex!].hasRecording = false
        userData.appointments[aptIndex!].timestamps = []
        self.reRecordPressed = false
        self.record()
    }
    
    /*
     Function for pausing a session
     */
    func pause() -> Void {
        self.testBool = false
        audioRecorder!.pause()
    }
    
    /*
     Function for marking a time point in a recording
     TODO: set up timestamp storage, look into possibly adding NSSpeechRecognizer functionality
     */
    func mark() -> Void {
        print("\(audioRecorder!.currentTime)")
        userData.appointments[aptIndex!].timestamps.append(audioRecorder!.currentTime)
    }
    
    /*
     Function for ending a recording
     */
    func end() -> Void {
        self.testBool = false
        self.beganRecording = false
        self.endPressed = false
        userData.appointments[aptIndex!].hasRecording = true
        audioRecorder!.stop()
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        HStack {
            // Record/Pause button, check first to see if we are in a warning mode
            if (!self.endPressed && !self.reRecordPressed) {
                // Check to confirm that the recorder is set up
                if (audioRecorder == nil) {
                    Text("Recorder Error")
                } else if (!self.testBool) {
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
                    // And a marker button (for marking the time for later
                    Button(action: {self.mark()}) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    .padding(.leading)
                }
                Spacer()
                // If we have a recording, display the play button
                if (userData.appointments[aptIndex!].hasRecording) {
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
                            .foregroundColor(self.testBool ? .red : .gray)
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
            AppointmentRecordingPlay(appointment: self.userData.appointments[self.aptIndex!])  // Sheet for playing an audio file
        }
    }
}

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording(id: 0).environmentObject(UserData())
    }
}
