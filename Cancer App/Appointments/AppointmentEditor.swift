//
//  AppointmentEditor.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentEditor: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var deletePressed = false
    var appointment: Appointment
    
    var aptIndex: Int? {
        userData.appointments.firstIndex(where: {$0.id == appointment.id})
    }
    
    func delete() -> Void {
        userData.appointments.remove(at: aptIndex!)
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func cancel() -> Void {
        userData.appointments[aptIndex!].doctor = appointment.doctor
        userData.appointments[aptIndex!].location = appointment.location
        userData.appointments[aptIndex!].date = appointment.date
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        List {
            if (aptIndex != nil) {
                HStack {
                    Text("Doctor")
                        .font(.headline)
                    Divider()
                    TextField("Doctor", text: $userData.appointments[aptIndex!].doctor)
                }

                HStack {
                    Text("Location")
                        .font(.headline)
                    Divider()
                    TextField("Location", text: $userData.appointments[aptIndex!].location)
                }
                
                DatePicker(selection: .constant(userData.appointments[aptIndex!].date), label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
                
                HStack {
                    if (!self.deletePressed) {
                        Button(action: {self.deletePressed.toggle()}) {
                            HStack {
                                Text("Delete")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "trash")
                                    .imageScale(.large)
                            }
                        }
                    } else {
                        HStack {
                            Text("Are you sure you want to delete this?")
                                .foregroundColor(.red)
                            Spacer()
                            Button(action: {self.deletePressed.toggle()}) {
                                Text("No")
                                    .foregroundColor(.blue)
                            }
                            Divider()
                            Button(action: {self.delete()}) {
                                Text("Yes")
                                    .foregroundColor(.red)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                Button(action: {self.cancel()}) {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct AppointmentEditor_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentEditor(appointment: UserData().appointments[0]).environmentObject(UserData())
    }
}
