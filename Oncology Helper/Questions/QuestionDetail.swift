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
    @State var playing: DescribedTimestamp?
    @State private var editMode = false
    @State var addAppointments = false
    @Binding var reload: Bool
    let question: Question
    
    // MARK: - initializer
    
    init(question: Question, reload: Binding<Bool>) {
        self.question = question
        _reload = reload
        UINavigationBar.appearance().backgroundColor = Constants.backgroundUIColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: Constants.titleUIColor]
    }
    
    // MARK: - body
    
    var body: some View {
        if reload {}
        let showModal = Binding<Bool>(get: {
            return self.editMode || self.addAppointments
        }, set: { p in
            self.editMode = p
            self.addAppointments = p
        })

        return AnyView(GeometryReader { geo in
            ZStack {
                AudioPlayerView(audioPlayer: self.$audioPlayer, playing: self.$playing)
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        HStack {
                            Text(self.question.questionString)
                                .font(.headline)
                                .foregroundColor(Constants.titleColor)
                                .multilineTextAlignment(.leading)
                                .padding()
                            Spacer()
                        }
                        if (self.question.description != nil) {
                            HStack {
                                Text(self.question.description!)
                                    .font(.subheadline)
                                    .foregroundColor(Constants.bodyColor)
                                    .multilineTextAlignment(.leading)
                                    .padding([.leading, .trailing])
                                    .padding(.top, -10)
                                    .padding(.bottom, 10.0)
                                Spacer()
                            }
                        }
                    }
                    .frame(width: geo.size.width)
                    .background(Constants.backgroundColor)
                    List {
                        ForEach(self.question.appointmentIDs, id: \.self) { id in
                            QuestionAppointmentView(appointmentID: id,
                                                    question: self.question,
                                                    audioPlayer: self.$audioPlayer,
                                                    playing: self.$playing,
                                                    reload: self.$reload)
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
                            QuestionEditor(question: self.question)
                                .environmentObject(self.userData)
                        } else {
                            QuestionAppointmentAdder(question: self.question)
                                .environmentObject(self.userData)
                        }
                    }
                    .onDisappear(perform: {self.reload.toggle()})
                }
            }
        })
    }
}

// MARK: - UIKit

private class AudioPlayerUIView: UIView {
    private let audioPlayer: Binding<AVPlayer?>
    private let playing: Binding<DescribedTimestamp?>
    private var timeObserverToken: Any?
    private var endObserverToken: Any?
    
    init(audioPlayer: Binding<AVPlayer?>, playing: Binding<DescribedTimestamp?>) {
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
    @Binding var playing: DescribedTimestamp?
    
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
        QuestionDetail(question: Question.default, reload: .constant(false))
            .environmentObject(UserData())
    }
}
