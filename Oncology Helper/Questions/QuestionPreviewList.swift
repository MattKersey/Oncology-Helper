//
//  QuestionPreviewList.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/9/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionPreviewList: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Binding var selectedQuestion: Question?
    @Binding var seeAllQuestions: Bool
    @State var newQuestion = ""
    
    var pinned: [Question] {
        var pinnedList: [Question] = []
        for question in userData.questions {
            if question.pin {
                pinnedList.append(question)
            }
        }
        return pinnedList
    }
    
    // MARK: - functions
    
    func submitNewQuestion() -> Void {
        guard newQuestion != "" else {
            return
        }
        var id: Int = 1
        for question in userData.questions {
            id = question.id > id ? question.id : id
        }
        userData.questions.append(Question(id: id + 1,
                                           questionString: newQuestion,
                                           description: nil,
                                           pin: true,
                                           appointmentIDs: []))
        newQuestion = ""
    }
    
    // MARK: - body
    
    var body: some View {
        let pinnedList = pinned
        
        return VStack(spacing: 0) {
            HStack {
                TextField("Add a question", text: $newQuestion)
                    .foregroundColor(Constants.titleColor)
                    .padding()
                Spacer()
                
                Button(action: self.submitNewQuestion) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding()
                .frame(height: 50)
                .background(Constants.itemColor)
            }
            .frame(height: 50)
            .buttonStyle(BorderlessButtonStyle())
            Divider()
            List {
                if !pinnedList.isEmpty {
                    ForEach(pinnedList) { question in
                        Button(action: {self.selectedQuestion = question}) {
                            Text("\(question.questionString)")
                                .font(.body)
                                .foregroundColor(Constants.titleColor)
                        }
                    }
                } else {
                    ForEach(0..<(userData.questions.count > 5 ? 5 : userData.questions.count)) { index in
                        Button(action: {self.selectedQuestion = self.userData.questions[index]}) {
                            Text("\(self.userData.questions[index].questionString)")
                                .font(.body)
                                .foregroundColor(Constants.titleColor)
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button(action: {self.seeAllQuestions = true}) {
                        Text("See All")
                            .foregroundColor(.blue)
                            .font(.callout)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - previews

struct QuestionPreviewList_Previews: PreviewProvider {
    static var previews: some View {
        QuestionPreviewList(selectedQuestion: .constant(nil), seeAllQuestions: .constant(false))
            .environmentObject(UserData())
    }
}
