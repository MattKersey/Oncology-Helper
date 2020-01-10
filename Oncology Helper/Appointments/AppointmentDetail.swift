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
    
    var dateString: String? {
        guard appointment != nil else {return nil}
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: appointment!.date)
    }
    
    // MARK: - body
    
    var body: some View {
        VStack {
            if (appointment != nil) {
                AppointmentPage(id: id).environmentObject(self.userData)
                .navigationBarTitle(Text("\(appointment!.doctor) | \(dateString!)"))
                .navigationBarItems(trailing: Button(action: {self.editMode = true}){Image(systemName: "square.and.pencil")})
                .sheet(isPresented: self.$editMode){
                    AppointmentEditor(appointment: self.appointment!, selectedTime:  self.appointment!.date).environmentObject(self.userData)
                }
            } else {
                Text("Appointment unavailable")
            }
            Spacer()
        }
    }
}

// MARK: - previews

struct AppointmentDetail_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetail(id: 1).environmentObject(UserData())
    }
}
