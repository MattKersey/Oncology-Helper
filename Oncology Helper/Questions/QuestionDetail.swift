//
//  QuestionDetail.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/10/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionDetail: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.editMode) var mode
    @State private var editMode = false
    let id: Int
    
    var question: Question? {
        if let question = userData.questions.first(where: {$0.id == id}) {
            return question
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    // MARK: - initializer
    
    init(id: Int) {
        self.id = id
        UINavigationBar.appearance().backgroundColor = Constants.backgroundUIColor
    }
    
    // MARK: - body
    
    var body: some View {
        guard let question = self.question else {
            return AnyView(Text("Question unavailable").foregroundColor(Constants.subtitleColor))
        }

        return AnyView(NavigationView {
            List {
                if (question.description != nil) {
                    HStack {
                        Text(question.description!)
                            .font(.subheadline)
                            .foregroundColor(Constants.subtitleColor)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                ForEach(question.appointmentTimestamps, id: \.self) { appointmentTimestamps in
                    QuestionAppointmentView(appointmentTimestamps: appointmentTimestamps)
                        .environmentObject(self.userData)
                }
            }
            .navigationBarTitle(Text(question.questionString), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.editMode = true}){Image(systemName: "square.and.pencil")})
        })
    }
}

// MARK: - previews

struct QuestionDetail_Previews: PreviewProvider {
    static var previews: some View {
        QuestionDetail(id: 1)
            .environmentObject(UserData())
    }
}
