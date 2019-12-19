//
//  AppointmentRecording.swift
//  Cancer App
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
    @State var hasRecording = false             // If there is a recording in memory
                                                    // TODO: Replace with var in appointment
    @State var reRecordPressed = false          // If record has been pressed with recording in memory
    @State var playPressed = false              // If the play button has been pressed
    
    var audioRecorder = AVAudioRecorder()       // Audio recorder object
                                                    // TODO: Initialize with URL from appointment
    
/**************************************** Functions ********************************************/
    
    /*
     Function for starting or resuming a recording
     */
    func record() -> Void {
        // Check to see if we are erasing a file so we can warn the user
        if (self.hasRecording) {
            self.reRecordPressed = true
        } else {
            // Check to see if we are beginning a new recording
            if (!self.beganRecording) {
                // Initialize audio file
                audioRecorder.prepareToRecord()
                self.beganRecording = true
            }
            self.testBool = true
            audioRecorder.record()
        }
    }
    
    /*
     Function for recording a new session over one that already exists
     */
    func reRecord() -> Void {
        self.hasRecording = false
        self.reRecordPressed = false
        self.record()
    }
    
    /*
     Function for pausing a session
     */
    func pause() -> Void {
        self.testBool = false
        audioRecorder.pause()
    }
    
    /*
     Function for marking a time point in a recording
     TODO: set up timestamp storage, look into possibly adding NSSpeechRecognizer functionality
     */
    func mark() -> Void {
        audioRecorder.currentTime
    }
    
    /*
     Function for ending a recording
     */
    func end() -> Void {
        self.testBool = false
        self.beganRecording = false
        self.endPressed = false
        self.hasRecording = true
        audioRecorder.stop()
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        HStack {
            // Record/Pause button, check first to see if we are in a warning mode
            if (!self.endPressed && !self.reRecordPressed) {
                // Check to see if we are currently recording
                if (!self.testBool) {
                    // If not, display a record button
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
                    // If so, display a pause button
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
                if (self.hasRecording) {
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
            AppointmentRecordingPlay(hasRecording: self.$hasRecording)  // Sheet for playing an audio file
        }
    }
}

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording(id: 0).environmentObject(UserData())
    }
}
