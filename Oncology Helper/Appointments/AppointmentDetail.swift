//
//  AppointmentDetail.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct AppointmentDetail: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.editMode) var mode
    @State private var editMode = false
    var id: Int
    
    var appointment: Appointment? {
        if let apt = userData.appointments.first(where: {$0.id == id}) {
            return apt
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    // MARK: - body
    
    var body: some View {
        VStack {
            if (appointment != nil) {
                AppointmentPage(id: id).environmentObject(self.userData)
            } else {
                Text("Appointment unavailable")
            }
            Spacer()
        }
        .navigationBarTitle(Text(appointment!.doctor))
        .navigationBarItems(trailing: Button(action: {self.editMode = true}){Image(systemName: "square.and.pencil")})
        .sheet(isPresented: self.$editMode){
            AppointmentEditor(appointment: self.appointment!, selectedTime:  self.appointment!.date).environmentObject(self.userData)
        }
    }
}

// MARK: - previews

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(id: 1).environmentObject(UserData())
    }
}
