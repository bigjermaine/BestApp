//
//  StoryDetailView.swift
//  BestApp
//  Created by Daniel Jermaine on 18/06/2025.


import AVFoundation
import DSWaveformImage
import DSWaveformImageViews
import SwiftUI

struct Story {
    var name:String
}
struct StoryDetailView: View {
    let stories: [Story] = [Story(name: ""),Story(name: "")]
    var user: UserModel
    var onSubmit: (UserModel) -> Void
    @State private var dragOffset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteZone: Bool = false
    @State private var localUser: UserModel
    @State private var animationTimer: Timer?
    @EnvironmentObject var recordingViewModel:RecordingViewModel
    @State private var currentIndex = 0
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    init(user: UserModel, onSubmit: @escaping (UserModel) -> Void) {
          self.user = user
          self.onSubmit = onSubmit
          _localUser = State(initialValue: user) // initialize local copy
      }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(user.imageName)
                .resizable()
                .frame(width: geometry.size.width, height: geometry.size.height + 20)
                .clipped()
                .ignoresSafeArea()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.6), Color.clear, Color.black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                VStack {
                    HStack(spacing: 4) {
                        ForEach(0..<stories.count, id: \.self) { index in
                            StoryProgressBar(progress: progressFor(index))
                        }
                    }
                    .frame(height: 10)
                    .padding(.horizontal)
                    
                    topHeader
                    Spacer()
                    Spacer()
                    questionContent
                    Spacer()
                    recordingInterface
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                if showDeleteZone {
                    deleteZoneOverlay
                }
            }
            .onTapGesture {
                nextStory()
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            recordingViewModel.stopRecording()
        }
        .onAppear {
                   startProgress()
               }
               .onDisappear {
                   timer?.invalidate()
               }
           }

           private func progressFor(_ index: Int) -> CGFloat {
               if index < currentIndex {
                   return 1.0
               } else if index == currentIndex {
                   return progress
               } else {
                   return 0.0
               }
           }

           private func startProgress() {
               progress = 0.0
               timer?.invalidate()
               timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                   if progress < 1.0 {
                       progress += 0.01
                   } else {
                       nextStory()
                   }
               }
           }

           private func nextStory() {
               if currentIndex < stories.count - 1 {
                   currentIndex += 1
                   startProgress()
               } else {
                   dismiss() // Close story view
               }
           }

           private func prevStory() {
               if currentIndex > 0 {
                   currentIndex -= 1
                   startProgress()
               }
           }
    
    
    private var topHeader: some View {
        HStack {
            Button{
                dismiss()
            }label:{
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
           
            Text("\(user.name), \(user.age)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
       
    }
    
    private var questionContent: some View {
        VStack(spacing: 16) {
            VStack {
                Image(user.imageName)
            .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                
                Text("Stroll question")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
            }
            Text(user.question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text(user.sampleAnswer)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Recording Interface
    private var recordingInterface: some View {
        VStack(spacing: 20) {
            if recordingViewModel.isRecording || recordingViewModel.isPlaying  {
                VStack(spacing: 12) {
                    if !recordingViewModel.isPlaying {
                        Text(recordingViewModel.formatTime(recordingViewModel.recordingTime))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }else {
                        Text(recordingViewModel.playerTime)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    waveformView
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Bottom controls
            HStack(spacing: 40) {
                if recordingViewModel.isRecording || recordingViewModel.isPlaying {
                    Button(action: recordingViewModel.cancelRecording) {
                        Text("Delete")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    Spacer()
                        .frame(width: 60)
                }
                
                // Record button
                recordButton
                if recordingViewModel.isRecording || recordingViewModel.isPlaying{
                    Button {
                        recordingViewModel.submitRecording()
                        localUser.isRecorded = true
                        onSubmit(localUser)
                        dismiss()
                        
                    }label: {
                        
                        Text("Submit")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Spacer()
                        .frame(width: 60)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
            
            if !recordingViewModel.isRecording {
                Button(action: {}) {
                    Text("Unmatch")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                .padding(.bottom, 40)
            }
        }
    }
    

    private var recordButton: some View {
        Button {
            recordingViewModel.toggleRecording()
            timer?.invalidate()
            
        }label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(recordingViewModel.isRecording ? Color.red : Color.gray.opacity(0.6))
                    .frame(width: recordingViewModel.isRecording ? 30 : 60, height: recordingViewModel.isRecording ? 30 : 60)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: recordingViewModel.isRecording)
                
                if !recordingViewModel.isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .scaleEffect(recordingViewModel.isRecording ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: recordingViewModel.isRecording)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if recordingViewModel.isRecording  {
                        dragOffset = value.translation
                        showDeleteZone = value.translation.width < -100
                    }
                }
                .onEnded { value in
                    if recordingViewModel.isRecording {
                        if value.translation.height < -100 {
                            // Cancel recording
                            recordingViewModel.cancelRecording()
                        }
                        dragOffset = .zero
                        showDeleteZone = false
                    }
                }
        )
    }
     
    
    // MARK: - Waveform View
    private var waveformView: some View {
        HStack() {
            if recordingViewModel.isPlaying {
                GeometryReader { geometry in
                    ZStack {
                        WaveformView(
                            audioURL: recordingViewModel.recordingURL!,
                            configuration: Waveform.Configuration(
                                size: CGSize(width: 10, height: 60), // Adjust height for boxiness
                                damping: .init(percentage: 0.125, sides: .both)
                            ),
                            renderer:LinearWaveformRenderer()
                        ) { waveformShape in
                            waveformShape
                                .stroke(
                                    Color.purple,
                                    style: StrokeStyle(
                                        lineWidth: 4,
                                        lineCap: .butt,
                                        dash: [4, 4] // <- Create broken lines
                                    )
                                )
                                .mask(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width * recordingViewModel.playbackProgress)
                                }
                        }
                        .frame(height: 60)
                    }
                    .padding()
                }
            
              }else {
                WaveformLiveCanvas(
                    samples: recordingViewModel.audioLevels,
                    configuration: recordingViewModel.liveConfiguration,
                    renderer: LinearWaveformRenderer(), shouldDrawSilencePadding: recordingViewModel.silence)
            }
          
        }
        .frame(maxWidth:.infinity,maxHeight: 40)
        .padding(.horizontal,20)
        
        
    }
    
    // MARK: - Delete Zone Overlay
    private var deleteZoneOverlay: some View {
        VStack {
            VStack(spacing: 16) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
                
                Text("Release to delete")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
        }
        .padding(.top, 150)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

   
   
}
#Preview {
    StoryDetailView(user: DummyUserDatabase.users.first!, onSubmit: {_ in })
        .environmentObject(previewData2)
}
