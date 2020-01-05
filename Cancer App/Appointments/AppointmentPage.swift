//
//  AppointmentPage.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/18/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AppointmentPage: View {
    var appointment: Appointment
    var audioSession: AVAudioSession? {
        var session: AVAudioSession? = AVAudioSession.sharedInstance()
        do {
            try session!.setCategory(.playAndRecord)
            try session!.setActive(true)
            session!.requestRecordPermission() { allowed in
                if !allowed {
                    session = nil
                }
            }
        } catch {
            return nil
        }
        return session
    }
    
    var body: some View {
        List {
            AppointmentRow(appointment: appointment)
            if (audioSession != nil) {
                AppointmentRecording(id: appointment.id).environmentObject(UserData())
            }
        }
    }
}

struct AppointmentPage_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentPage(appointment: UserData().appointments[0])
    }
}
