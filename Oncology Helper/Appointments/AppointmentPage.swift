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
    @EnvironmentObject var userData: UserData
    var id: Int
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == id}) {
            return apt
        } else {
            return nil
        }
    }
    
    var audioSession: AVAudioSession? {
        var session: AVAudioSession? = AVAudioSession.sharedInstance()
        do {
            try session!.setCategory(.playAndRecord, mode: .default)
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
        VStack {
            List {
                if (audioSession != nil) {
                    AppointmentRecording(appointmentId: appointment!.id).environmentObject(self.userData)
                }
            }
        }
    }
}

struct AppointmentPage_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentPage(id: 1).environmentObject(UserData())
    }
}
