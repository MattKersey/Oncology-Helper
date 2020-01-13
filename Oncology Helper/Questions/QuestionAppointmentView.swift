//
//  QuestionAppointmentView.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/12/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionAppointmentView: View {
    @EnvironmentObject var userData: UserData
    @State var showTimes = false
    let appointmentTimestamps: AppointmentTimestamps
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == appointmentTimestamps.id}) {
            return apt
        } else {
            return nil
        }
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: appointment!.date)
    }
    
    var body: some View {
        guard let appointment = self.appointment else {
            return AnyView(Text(""))
        }
        return AnyView(Group {
            HStack {
                VStack(alignment: .leading) {
                    Text(appointment.doctor)
                        .font(.headline)
                    Text(dateString)
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right.circle")
                    .scaleEffect(1.5)
            }
            ForEach(appointmentTimestamps.timestamps, id: \.self) { timestamp in
                HStack {
                    Text(verbatim: String(format: "%.1f", timestamp))
                        .padding(.leading)
                    Spacer()
                    Image(systemName: "doc.text")
                    Divider()
                    Image(systemName: "play.fill")
                }
                .opacity(0.65)
            }
        })
    }
}

struct QuestionAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAppointmentView(appointmentTimestamps: AppointmentTimestamps(id: 1, timestamps: []))
            .environmentObject(UserData())
    }
}
