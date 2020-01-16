//
//  Question.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/9/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI

class Question: Hashable, Codable, Identifiable {
    
    static let `default` = UserData().questions[0]
    
    // MARK: - instance properties
    
    let id: Int
    var questionString: String
    var description: String?
    var pin: Bool
    var appointmentIDs: [Int]
    
    // MARK: - functions
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: Int, questionString: String, description: String?, pin: Bool, appointmentIDs: [Int]) {
        self.id = id
        self.questionString = questionString
        self.description = description
        self.pin = pin
        self.appointmentIDs = appointmentIDs
    }
}
