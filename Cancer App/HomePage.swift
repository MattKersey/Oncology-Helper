//
//  HomePage.swift
//  Cancer App
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var userData: UserData
    var currentDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.appointments) { appointment in
                    if appointment.date > self.currentDate {
                        NavigationLink(destination: AppointmentDetail(id: appointment.id).environmentObject(self.userData)
                        ) {
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Upcoming"))
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserData())
    }
}
