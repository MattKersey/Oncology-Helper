//
//  UserData.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 12/16/19.
//  Copyright © 2019 Matt Kersey. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation

final class UserData: ObservableObject {
    
    // MARK: - published properties
    
    @Published var appointments = appointmentData
    @Published var questions = questionData
    @Published var audioSession: AVAudioSession?
    
    // MARK: - functions
    
    public func deleteAppointment(index: Int) {
        let appointmentID = appointments[index].id
        let questionIDs = appointments[index].questionIDs
        appointments.remove(at: index)
        for id in questionIDs {
            removeQAConnection(appointmentID: appointmentID, questionID: id)
        }
    }
    
    public func deleteQuestion(index: Int) {
        let questionID = questions[index].id
        for appointmentTimestamp in questions[index].appointmentTimestamps {
            removeQAConnection(appointmentID: appointmentTimestamp.id, questionID: questionID)
        }
        questions.remove(at: index)
    }
    
    public func removeQAConnection(appointmentID: Int, questionID: Int) {
        if let qIndex = questions.firstIndex(where: {$0.id == questionID}) {
            questions[qIndex].appointmentTimestamps.removeAll(where: {$0.id == appointmentID})
        }
        if let aptIndex = appointments.firstIndex(where: {$0.id == appointmentID}) {
            appointments[aptIndex].questionIDs.removeAll(where: {$0 == questionID})
            appointments[aptIndex].describedTimestamps.removeAll(where: {$0.id == questionID})
        }
    }
    
    public func addTimestamp(appointmentID: Int,
                             questionID: Int? = nil,
                             timestamp: TimeInterval,
                             sort: Bool = false) {
        guard let aptIndex = appointments.firstIndex(where: {$0.id == appointmentID}) else {
            return
        }
        let describedTimestamp = DescribedTimestamp(id: questionID,
                                                    description: nil,
                                                    timestamp: timestamp)
        if sort {
            var index = 0
            for describedTimestamp in appointments[aptIndex].describedTimestamps {
                if describedTimestamp.timestamp > timestamp {
                    break
                }
                index += 1
            }
            appointments[aptIndex].describedTimestamps.insert(describedTimestamp, at: index)
        } else {
            appointments[aptIndex].describedTimestamps.append(describedTimestamp)
        }
        
        guard questionID != nil else {
            return
        }
        guard let qIndex = questions.firstIndex(where: {$0.id == questionID!}) else {
            return
        }
        guard let qAptIndex = questions[qIndex].appointmentTimestamps.firstIndex(where: {$0.id == appointmentID}) else {
            return
        }
        if sort {
            var index = 0
            for qTimestamp in questions[qIndex].appointmentTimestamps[qAptIndex].timestamps {
                if qTimestamp > timestamp {
                    break
                }
                index += 1
            }
            questions[qIndex].appointmentTimestamps[qAptIndex].timestamps.insert(timestamp, at: index)
        } else {
            questions[qIndex].appointmentTimestamps[qAptIndex].timestamps.append(timestamp)
        }
    }
    
    public func deleteTimestamp(appointmentID: Int, timestamp: TimeInterval) {
        guard let aptIndex = appointments.firstIndex(where: {$0.id == appointmentID}) else {
            return
        }
        guard let timeIndex = appointments[aptIndex].describedTimestamps.firstIndex(where: {$0.timestamp == timestamp}) else {
            return
        }
        let id = appointments[aptIndex].describedTimestamps[timeIndex].id
        appointments[aptIndex].describedTimestamps.remove(at: timeIndex)
        guard let questionID = id else {
            return
        }
        guard let qIndex = questions.firstIndex(where: {$0.id == questionID}) else {
            return
        }
        guard let qAptIndex = questions[qIndex].appointmentTimestamps.firstIndex(where: {$0.id == appointmentID}) else {
            return
        }
        questions[qIndex].appointmentTimestamps[qAptIndex].timestamps.removeAll(where: {$0 == timestamp})
    }
    
    // MARK: - initializer
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession!.setCategory(.playAndRecord, mode: .default)
            try audioSession!.setActive(true)
            audioSession!.requestRecordPermission() { allowed in
                if !allowed {
                    self.audioSession = nil
                }
            }
        } catch {
            audioSession = nil
        }
    }
}
