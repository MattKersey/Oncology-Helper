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
/**************************************** Variables ********************************************/
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var doctor = ""                          // Binding for storing doctor's name
    @State var location = ""                        // Binding for storing location
    @State var date: Date                     // Binding for storing date, today by default
    
/**************************************** Functions ********************************************/
    
    /*
     Function for finishing up and storing the new appointment in the JSON file
     */
    func done() -> Void {
        // Find the proper index for the new appointment s.t. the array is sorted by date
        var index = 0
        for apt in userData.appointments {
            if apt.date > date {
                break
            }
            index += 1
        }
        var id = 1
        for apt in userData.appointments {
            id = apt.id > id ? apt.id : id
        }
        // Insert new appointment from the bindings
        userData.appointments.insert(Appointment(id: id + 1, doctor: doctor, location: location, RC3339date: "1995-01-01T12:00:00+00:00"), at: index)
        userData.appointments[index].date = date
        // Close sheet
        self.presentationMode.wrappedValue.dismiss()
    }
    
/**************************************** Main View ********************************************/
    
    var body: some View {
        List {
            // Doctor name field
            HStack {
                Text("Doctor")
                    .font(.headline)
                Divider()
                TextField("Doctor", text: $doctor)
            }
            // Location name field
            HStack {
                Text("Location")
                    .font(.headline)
                Divider()
                TextField("Location", text: $location)
            }
            // Date picker for appointment
            DatePicker(selection: $date, displayedComponents: .hourAndMinute, label: { Text("Time") })
            
            // Done button
            Button(action: {self.done()}) {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
        }
    }
}

struct AppointmentAdder_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentAdder(date: Date()).environmentObject(UserData())
    }
}
