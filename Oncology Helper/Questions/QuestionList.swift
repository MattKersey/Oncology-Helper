//
//  QuestionList.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/14/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

struct QuestionList: View {
    @EnvironmentObject var userData: UserData
    @State private var isAddingQuestion = false
    @State private var reload = false
    
    func pinToggle(question: Question) {
        question.pin.toggle()
        reload.toggle()
    }
    
    init() {
        UINavigationBar.appearance().backgroundColor = Constants.backgroundUIColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: Constants.titleUIColor]
    }
    
    var body: some View {
        if reload {}
        return NavigationView {
            List {
                ForEach(userData.questions) { question in
                    NavigationLink(destination: QuestionDetail(question: question, reload: self.$reload).environmentObject(self.userData)) {
                        HStack {
                            Button(action: {self.pinToggle(question: question)}) {
                                Image(systemName: question.pin ? "pin.fill" : "pin")
                                    .foregroundColor(question.pin ? Constants.itemColor : Constants.subtitleColor)
                            }
                            .scaleEffect(0.75)
                            .padding(.trailing, 5.0)
                            Text(question.questionString)
                                .font(.body)
                                .foregroundColor(Constants.titleColor)
                            Spacer()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {self.isAddingQuestion = true}) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isAddingQuestion) {
                QuestionAdder()
                    .environmentObject(self.userData)
            }
        }
    }
}

struct QuestionList_Previews: PreviewProvider {
    static var previews: some View {
        QuestionList()
            .environmentObject(UserData())
    }
}
