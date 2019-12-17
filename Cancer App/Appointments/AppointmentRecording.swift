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
    var audioRecorder = AVAudioRecorder()
    
    func record() -> Void {
        
    }
    
    func pause() -> Void {
        
    }
    
    func mark() -> Void {
        
    }
    
    var body: some View {
        HStack {
            ZStack {
                if (!audioRecorder.isRecording) {
                    Button(action: {self.record()}) {
                        Image("RecordButton")
                    }
                } else {
                    Button(action: {self.pause()}) {
                        Image(systemName: "pause.circle.fill")
                        .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .scaleEffect(1.5)
            if (audioRecorder.isRecording) {
                Button(action: {self.mark()}) {
                    Image(systemName: "flag.circle.fill")
                        .foregroundColor(.red)
                        .scaleEffect(1.5)
                }
            }
            Spacer()
        }
    }
}

struct AppointmentRecording_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecording()
    }
}
