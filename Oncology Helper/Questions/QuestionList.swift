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
    
    init() {
        UINavigationBar.appearance().backgroundColor = Constants.backgroundUIColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: Constants.titleUIColor]
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userData.questions.indices) { index in
                    NavigationLink(destination: QuestionDetail(id: self.userData.questions[index].id).environmentObject(self.userData)) {
                        HStack {
                            Button(action: {self.userData.questions[index].pin.toggle()}) {
                                Image(systemName: self.userData.questions[index].pin ? "pin.fill" : "pin")
                                    .foregroundColor(self.userData.questions[index].pin ? Constants.itemColor : Constants.subtitleColor)
                            }
                            .scaleEffect(0.75)
                            .padding(.trailing, 5.0)
                            Text(self.userData.questions[index].questionString)
                                .font(.body)
                                .foregroundColor(Constants.titleColor)
                            Spacer()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
        }
    }
}

struct QuestionList_Previews: PreviewProvider {
    static var previews: some View {
        QuestionList()
            .environmentObject(UserData())
    }
}
