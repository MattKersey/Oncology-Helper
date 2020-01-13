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
    
    var pinned: [Question] {
        var pinnedList: [Question] = []
        for question in userData.questions {
            if question.pin {
                pinnedList.append(question)
            }
        }
        return pinnedList
    }
    
    // MARK: - body
    
    var body: some View {
        let pinnedList = pinned
        
        return List {
            if userData.questions.isEmpty {
                Text("No Questions")
            }
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
                    Text("\(self.userData.questions[index].questionString)")
                        .font(.body)
                        .foregroundColor(Constants.titleColor)
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

// MARK: - previews

struct QuestionPreviewList_Previews: PreviewProvider {
    static var previews: some View {
        QuestionPreviewList(selectedQuestion: .constant(nil), seeAllQuestions: .constant(false))
            .environmentObject(UserData())
    }
}
