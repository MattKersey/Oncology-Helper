
//
//  AppointmentRecordingPlay.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/18/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentRecordingPlay: View {
/**************************************** Variables ********************************************/
    
    var appointment: Appointment
    
/**************************************** Functions ********************************************/
    
    var body: some View {
        List {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            ForEach(appointment.timestamps, id: \.self) { timestamp in
                Text("\(timestamp)")
            }
        }
    }
}

/**************************************** Preview ********************************************/

struct AppointmentRecordingPlay_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentRecordingPlay(appointment: UserData().appointments[0])
    }
}
