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
    @State var testBool = false
    @State var beganRecording = false
    @State var endPressed = false
    @State var hasRecording = false
    @State var reRecordPressed = false
    var audioRecorder = AVAudioRecorder()
    
    func record() -> Void {
        if (self.hasRecording) {
            self.reRecordPressed = true
        } else {
            self.testBool = true
            self.beganRecording = true
        }
    }
    
    func reRecord() -> Void {
        self.hasRecording = false
        self.reRecordPressed = false
        self.record()
    }
    
    func pause() -> Void {
        self.testBool = false
    }
    
    func mark() -> Void {
        
    }
    
    func reset() -> Void {
        
    }
    
    func end() -> Void {
        self.testBool = false
        self.beganRecording = false
        self.endPressed = false
        self.hasRecording = true
    }
    
    var body: some View {
        HStack {
            if (!self.endPressed && !self.reRecordPressed) {
                if (!self.testBool) {
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
                    Button(action: {self.pause()}) {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                }
                if (self.testBool) { //audioRecorder.isRecording) {
                    Button(action: {self.mark()}) {
                        Image(systemName: "flag.circle.fill")
                            .foregroundColor(.red)
                    }
                    .scaleEffect(2.0)
                    .padding()
                }
                Spacer()
                if (self.hasRecording) {
                    Button(action: {self.endPressed.toggle()}) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .scaleEffect(2.0)
                } else if (self.beganRecording) {
                    Button(action: {self.endPressed.toggle()}) {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(self.testBool ? .red : .gray)
                    }
                    .scaleEffect(2.0)
                }
            } else if (self.endPressed) {
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
    }
}

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording()
    }
}
