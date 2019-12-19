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
    @State var showAll = false
    var currentDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.userData.appointments) { appointment in
                    if appointment.date > self.currentDate {
                        NavigationLink(destination: AppointmentDetail(id: appointment.id).environmentObject(self.userData)
                        ) {
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }.onDelete(perform: self.delete)
            }
            .navigationBarTitle(Text("Upcoming"))
            .navigationBarItems(trailing: Button(action: {self.showAll = true}){Text("Show All")})
            .sheet(isPresented: self.$showAll){
                List {
                    ForEach(self.userData.appointments) { appointment in
                        NavigationLink(destination: AppointmentDetail(id: appointment.id).environmentObject(self.userData)
                        ) {
                            AppointmentRow(appointment: appointment)
                        }
                    }.onDelete(perform: self.delete)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        userData.appointments.remove(atOffsets: offsets)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserData())
    }
}
