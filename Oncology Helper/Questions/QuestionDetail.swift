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
    @State var addAppointments = false
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
        let showModal = Binding<Bool>(get: {
            return self.editMode || self.addAppointments
        }, set: { p in
            self.editMode = p
            self.addAppointments = p
        })

        return AnyView(GeometryReader { geo in
            NavigationView {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        HStack {
                            Text(question.questionString)
                                .font(.headline)
                                .foregroundColor(Constants.titleColor)
                                .multilineTextAlignment(.leading)
                                .padding([.top, .leading, .trailing])
                            Spacer()
                        }
                        if (question.description != nil) {
                            HStack {
                                Text(question.description!)
                                    .font(.subheadline)
                                    .foregroundColor(Constants.bodyColor)
                                    .multilineTextAlignment(.leading)
                                    .padding([.leading, .trailing])
                                    .padding(.top, 5.0)
                                    .padding(.bottom, 10.0)
                                Spacer()
                            }
                        }
                    }
                    .frame(width: geo.size.width)
                    .background(Constants.backgroundColor)
                    List {
                        ForEach(question.appointmentTimestamps, id: \.self) { appointmentTimestamps in
                            QuestionAppointmentView(appointmentTimestamps: appointmentTimestamps)
                                .environmentObject(self.userData)
                        }
                        Button(action: {self.addAppointments = true}) {
                            Text("Add more appointments")
                                .foregroundColor(.blue)
                                .font(.callout)
                        }
                    }
                    .navigationBarTitle(Text(""), displayMode: .inline)
                    .navigationBarItems(trailing: Button(action: {self.editMode = true}) {Image(systemName: "square.and.pencil")})
                    .sheet(isPresented: showModal) {
                        if self.editMode {
                            Text("Hello World")
                        } else {
                            QuestionAppointmentAdder(question: question)
                                .environmentObject(self.userData)
                        }
                    }
                }
            }
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
