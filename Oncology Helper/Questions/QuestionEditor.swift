//
//  QuestionEditor.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/15/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionEditor: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var question: Question
    @State var description: String
    
    var questionIndex: Int? {
        if let index = userData.questions.firstIndex(where: {$0.id == question.id}) {
            return index
        } else {
            self.presentationMode.wrappedValue.dismiss()
            return nil
        }
    }
    
    func cancel() {
        guard let qIndex = questionIndex else {return}
        question.questionString = userData.questions[qIndex].questionString
        if (userData.questions[qIndex].description == nil) {
            description = ""
        } else {
            description = userData.questions[qIndex].description!
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func save() {
        guard let qIndex = questionIndex else {return}
        userData.questions[qIndex].questionString = question.questionString
        if description == "" {
            userData.questions[qIndex].description = nil
        } else {
            userData.questions[qIndex].description = description
        }
    }
    
    init(question: Question) {
        _question = State(initialValue: question)
        if question.description == nil {
            _description = State(initialValue: "")
        } else {
            _description = State(initialValue: question.description!)
        }
    }
    
    var body: some View {
        guard questionIndex != nil else {
            return AnyView(Text("Question not found"))
        }
        return AnyView(GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("Question")
                            .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    TextField("Question", text: self.$question.questionString)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                    Divider()
                        .padding([.top, .bottom])
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(Constants.titleColor)
                    TextField("Optional Description", text: self.$description)
                        .foregroundColor(Constants.bodyColor)
                        .padding(.leading)
                }
                .padding()
                Spacer()
                Divider()
                Button(action: {self.cancel()}) {
                    HStack {
                        Spacer()
                        Text("Cancel")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .frame(height: 60)
                
                // Done button
                Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(height: 60)
                    .background(Constants.itemColor)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .onDisappear(perform: {self.save()})
            }
        )
    }
}

struct QuestionEditor_Previews: PreviewProvider {
    static var previews: some View {
        QuestionEditor(question: UserData().questions[0])
            .environmentObject(UserData())
    }
}
