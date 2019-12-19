
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
    var appointment: Appointment
    
    var body: some View {
        List {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            ForEach(appointment.timestamps, id: \.self) { timestamp in
                Text("\(timestamp)")
            }
        }
    }
}

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(hasRecording: .constant(true), appointment: UserData().appointments[0])
    }
}
