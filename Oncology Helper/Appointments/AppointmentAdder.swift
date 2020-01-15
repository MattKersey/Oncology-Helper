//
//  AppointmentAdder.swift
//  Oncology Helper
//
//  File for adding appointments to appointmentData.JSON via UserData.swift
//  Called by HomePage.swift
//
//  Created by Matt Kersey on 12/19/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentAdder: View {

    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var doctorString = ""                          // Binding for storing doctor's name
    @State var locationString = ""                        // Binding for storing location
    @State var date: Date                     // Binding for storing date, today by default
    
    // MARK: - functions
    
    func done() {
        // Find the proper index for the new appointment s.t. the array is sorted by date
        var index = 0
        for apt in userData.appointments {
            if apt.date > date {
                break
            }
            index += 1
        }
        var id = 0
        for apt in userData.appointments {
            id = apt.id > id ? apt.id : id
        }
        id += 1
        // Insert new appointment from the bindings
        userData.appointments.insert(Appointment(id: id,
                                                 doctor: doctorString,
                                                 location: locationString,
                                                 RC3339date: "1995-01-01T12:00:00+00:00"),
                                     at: index)
        userData.appointments[index].date = date
        // Close sheet
        self.presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - body
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                // Doctor name field
                VStack(alignment: .leading) {
                    Text("Doctor")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                        .padding(.top)
                    TextField("Doctor", text: $doctorString)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding([.top, .bottom])
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    TextField("Location", text: $locationString)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding(.top)
                    DatePicker(selection: $date, displayedComponents: .hourAndMinute, label: { Text("Time") })
                }
            }
            Spacer()
            // Done button
            if doctorString != "" && locationString != "" {
                Button(action: {self.done()}) {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(height: 60)
                    .background(Constants.itemColor)
                }
            } else {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 60)
                .background(Constants.subtitleColor)
            }
        }
    }
}

// MARK: - previews

struct AppointmentAdder_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentAdder(date: Date()).environmentObject(UserData())
    }
}
