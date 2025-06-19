//
//  StoryDetailView.swift
//  BestApp
//  Created by Daniel Jermaine on 18/06/2025.


import AVFoundation
import DSWaveformImage
import DSWaveformImageViews
import SwiftUI

struct StoryDetailView: View {
    var user: UserModel
    var onSubmit: (UserModel) -> Void
    @State private var dragOffset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteZone: Bool = false
    @State private var localUser: UserModel
    @State private var animationTimer: Timer?
    @EnvironmentObject var recordingViewModel:RecordingViewModel
    
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
        }
        .navigationBarHidden(true)
        .onDisappear {
            recordingViewModel.stopRecording()
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
                if recordingViewModel.isRecording {
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
                if recordingViewModel.isRecording {
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
        Button(action: recordingViewModel.toggleRecording) {
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
                ZStack{
                    WaveformView(audioURL: recordingViewModel.recordingURL!) { waveformShape in
                        waveformShape
                    }
//                    if let waveformImage = recordingViewModel.waveformImage {
//                        waveformImage
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth:.infinity,maxHeight: 40)
//                    }
                }
            }else {
                WaveformLiveCanvas(
                    samples: recordingViewModel.audioLevels,
                    configuration: recordingViewModel.liveConfiguration,
                    shouldDrawSilencePadding: recordingViewModel.silence)
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
