//
//  QuestionAppointmentView.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/12/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionAppointmentView: View {
    
    // MARK: - instance properties
    
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
    
    // MARK: - body
    
    var body: some View {
        guard let appointment = self.appointment else {
            return AnyView(Text(""))
        }
        return AnyView(Group {
            HStack {
                if !appointmentTimestamps.timestamps.isEmpty {
                    Button(action: {self.showTimes.toggle()}) {
                        Image(systemName: "chevron.right.circle")
                    }
                    .scaleEffect(1.5)
                    .foregroundColor(.black)
                    .rotationEffect(Angle(degrees: showTimes ? 90.0 : 0.0))
                    .padding(.trailing)
                } else {
                    Image(systemName: "chevron.right.circle")
                        .scaleEffect(1.5)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                NavigationLink(destination: AppointmentDetail(id: appointment.id)
                    .environmentObject(self.userData)) {
                        VStack(alignment: .leading) {
                            Text(appointment.doctor)
                                .font(.headline)
                            Text(dateString)
                                .font(.caption)
                        }
                        Spacer()
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            if showTimes {
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
            }
        })
    }
}

// MARK: - previews

struct QuestionAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAppointmentView(appointmentTimestamps: AppointmentTimestamps(id: 1, timestamps: []))
            .environmentObject(UserData())
    }
}
