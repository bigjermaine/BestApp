//
//  StoryDetailView.swift
//  BestApp
//  Created by Daniel Jermaine on 18/06/2025.

import SwiftUI
import AVFoundation

struct StoryDetailView: View {
    let user: UserModel
    @State private var isRecording: Bool = false
    @State private var recordingTime: TimeInterval = 0
    @State private var dragOffset: CGSize = .zero
    @State private var audioLevels: [Float] = Array(repeating: 0.0, count: 50)
    @State private var currentAudioLevel: Float = 0.0
    @State private var recordingTimer: Timer?
    @State private var audioRecorder: AVAudioRecorder?
    @State private var showDeleteZone: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var animationTimer: Timer?
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
            stopRecording()
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
            // Recording time and waveform
            if isRecording {
                VStack(spacing: 12) {
                    Text(formatTime(recordingTime))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    waveformView
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Bottom controls
            HStack(spacing: 40) {
                // Delete button (only visible when recording)
                if isRecording {
                    Button(action: cancelRecording) {
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
                
    
                if isRecording {
                    Button(action: submitRecording) {
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
            
            if !isRecording {
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
        Button(action: toggleRecording) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(isRecording ? Color.red : Color.gray.opacity(0.6))
                    .frame(width: isRecording ? 30 : 60, height: isRecording ? 30 : 60)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
                
                if !isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .scaleEffect(isRecording ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if isRecording {
                        dragOffset = value.translation
                        showDeleteZone = value.translation.width < -100
                    }
                }
                .onEnded { value in
                    if isRecording {
                        if value.translation.height < -100 {
                            // Cancel recording
                            cancelRecording()
                        }
                        dragOffset = .zero
                        showDeleteZone = false
                    }
                }
        )
     }
    
    // MARK: - Waveform View
    private var waveformView: some View {
        HStack(spacing: 2) {
            ForEach(0..<audioLevels.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 3, height: CGFloat(audioLevels[index]) * 30 + 2)
                    .animation(.easeInOut(duration: 0.1), value: audioLevels[index])
            }
        }
        .frame(height: 40)
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
    
    // MARK: - Recording Functions
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        isRecording = true
        recordingTime = 0
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateAudioLevels()
        }
        
        
        setupAudioRecording()
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        animationTimer?.invalidate()
        audioRecorder?.stop()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            dragOffset = .zero
        }
    }
    
    private func cancelRecording() {
        stopRecording()
    }
    
    private func submitRecording() {
        stopRecording()
        dismiss()
    }
    
    private func updateAudioLevels() {
        // Simulate audio level updates (replace with actual audio level monitoring)
        let newLevel = Float.random(in: 0.1...1.0)
        audioLevels.removeFirst()
        audioLevels.append(newLevel)
    }
    
    private func setupAudioRecording() {
        // Audio recording setup (simplified)
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default)
        try? audioSession.setActive(true)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        try? audioRecorder = AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
#Preview {
    StoryDetailView(user: DummyUserDatabase.users.first!)
}
