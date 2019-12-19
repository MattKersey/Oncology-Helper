
//
//  AppointmentRecordingPlay.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/18/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentRecordingPlay: View {
    @Binding var hasRecording: Bool
    
    var body: some View {
        List {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(hasRecording: .constant(true))
    }
}
