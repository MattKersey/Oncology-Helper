//
//  QuestionMarker.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/13/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionMarker: View {
    
    @EnvironmentObject var userData: UserData
//    let questionID: Int
//    let appointmentID: Int
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct QuestionMarker_Previews: PreviewProvider {
    static var previews: some View {
        QuestionMarker()
            .environmentObject(UserData())
    }
}
