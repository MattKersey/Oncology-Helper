//
//  QuestionDetail.swift
//  Oncology Helper
//
//  Created by Matt Kersey on 1/10/20.
//  Copyright © 2020 Matt Kersey. All rights reserved.
//

import SwiftUI
import AVFoundation

struct QuestionDetail: View {
    
    // MARK: - instance properties
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.editMode) var mode
    @State var audioPlayer: AVPlayer?
    @State var playing: IDTimestampSingle?
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
                            QuestionAppointmentView(appointmentID: appointmentTimestamps.id,
                                                    questionID: self.id,
                                                    audioPlayer: self.$audioPlayer,
                                                    playing: self.$playing)
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

// MARK: - UIKit

private class AudioPlayerUIView: UIView {
    private let audioPlayer: Binding<AVPlayer?>
    private let playing: Binding<IDTimestampSingle?>
    private var timeObserverToken: Any?
    private var endObserverToken: Any?
    
    init(audioPlayer: Binding<AVPlayer?>, playing: Binding<IDTimestampSingle?>) {
        self.audioPlayer = audioPlayer
        self.playing = playing
        super.init(frame: .zero)
        
//        let interval = CMTime(seconds: 0.02, preferredTimescale: 600)
//        timeObserverToken = audioPlayer.wrappedValue?.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
//            guard let self = self else {return}
//              // Check here to see if the time is out of range, ie after the end of the clip
//        }
        
        endObserverToken = NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didFinishPlaying(note: NSNotification) {
        self.audioPlayer.wrappedValue = nil
        self.playing.wrappedValue = nil
    }
    
    func removeObservers() {
        if (timeObserverToken != nil) {
            audioPlayer.wrappedValue?.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
        if (endObserverToken != nil) {
            NotificationCenter.default.removeObserver(endObserverToken!)
            endObserverToken = nil
        }
    }
}

private struct AudioPlayerView: UIViewRepresentable {
    @Binding var audioPlayer: AVPlayer?
    @Binding var playing: IDTimestampSingle?
    
    func makeUIView(context: UIViewRepresentableContext<AudioPlayerView>) -> UIView {
        let uiView = AudioPlayerUIView(audioPlayer: $audioPlayer, playing: $playing)
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<AudioPlayerView>) {
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let audioPlayerUIView = uiView as? AudioPlayerUIView else {
            return
        }
        audioPlayerUIView.removeObservers()
    }
}

// MARK: - previews

struct QuestionDetail_Previews: PreviewProvider {
    static var previews: some View {
        QuestionDetail(id: 1)
            .environmentObject(UserData())
    }
}
