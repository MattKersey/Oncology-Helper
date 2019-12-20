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
    @State var date = Date()                        // Binding for storing date, today by default
    
    var appointment: Appointment{                   // New appointment object
        // Find the highest id we have, make one greater than that
        var id = 1
        for apt in userData.appointments {
            id = apt.id > id ? apt.id : id
        }
        // Initialize to some values
        let apt = Appointment(id: id + 1, doctor: "", location: "", RC3339date: "1995-01-01T12:00:00+00:00")
        return apt
    }
    
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
        userData.appointments.insert(appointment, at: index)
        // Update values from the bindings
        userData.appointments[index].doctor = doctor
        userData.appointments[index].location = location
        userData.appointments[index].date = date
        // Other method for inserting new appointment via appending and sorting
//        userData.appointments.append(appointment)
//        userData.appointments.sort(by: {$0.date < $1.date})
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
            DatePicker(selection: $date, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
            
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
        AppointmentAdder().environmentObject(UserData())
    }
}
