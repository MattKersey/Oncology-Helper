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
    let question: Question
    @State var questionString: String
    @State var description: String
    
    func save() {
        question.questionString = questionString
        if description == "" {
            question.description = nil
        } else {
            question.description = description
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    init(question: Question) {
        self.question = question
        _questionString = State(initialValue: question.questionString)
        if question.description == nil {
            _description = State(initialValue: "")
        } else {
            _description = State(initialValue: question.description!)
        }
    }
    
    var body: some View {
        return AnyView(VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("Question")
                        .font(.headline)
                    .foregroundColor(Constants.titleColor)
                TextField("Question", text: self.$questionString)
                    .foregroundColor(Constants.bodyColor)
                    .padding(.leading)
                Divider()
                    .padding([.top, .bottom])
                Text("Optional Description")
                    .font(.headline)
                    .foregroundColor(Constants.titleColor)
                TextField("Optional Description", text: self.$description)
                    .foregroundColor(Constants.bodyColor)
                    .padding(.leading)
            }
            .padding()
            Spacer()
            Divider()
            Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .frame(height: 60)
            
            // Done button
            if questionString != "" {
                Button(action: {self.save()}) {
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
            } else {
                HStack {
                    Spacer()
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(height: 60)
                .background(Constants.subtitleColor)
            }
        }
        .buttonStyle(BorderlessButtonStyle())
        )
    }
}

struct QuestionEditor_Previews: PreviewProvider {
    static var previews: some View {
        QuestionEditor(question: Question.default)
            .environmentObject(UserData())
    }
}
