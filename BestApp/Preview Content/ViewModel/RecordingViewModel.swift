//
//  RecordingViewModel.swift
//  BestApp
//
//  Created by Daniel Jermaine on 18/06/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import DSWaveformImage


class RecordingViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    // MARK: - Published Properties (State)
    @Published var isRecording: Bool = false
    @Published var isPlaying: Bool = false
    @Published var recordingTime: TimeInterval = 0
    @Published var playerTime: String = ""
    @Published var audioLevels: [Float] = []
    @Published var currentAudioLevel: Float = 0.0
    @Published var waveformImage: Image? = nil
    @Published var silence: Bool = true

    // MARK: - Private Internal Properties
    @Published private var dragOffset: CGSize = .zero
    
    var liveConfiguration: Waveform.Configuration = .init(
        style: .striped(.init(color: .black, width: 3, spacing: 3))
    )
    
    private var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("recording.m4a")
    }
    
    var recordingTimer: Timer?
    var playerTimer: Timer?
    var animationTimer: Timer?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    func setupAudioSession() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    try session.setActive(true)
                } catch {
                    print("Failed to activate audio session: \(error)")
                }
            }
        }
    }
    
    private func setRecordingSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to set recording session: \(error)")
        }
    }
    
    private func setPlaybackSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to set playback session: \(error)")
        }
    }
    
    // MARK: - Recording Logic
    private func setupAudioRecording() {
        // Clean up previous recorder
        cleanupRecorder()
        
        guard let url = recordingURL else { return }
        
        // Delete existing file to avoid conflicts
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func startRecording() {
        // Set proper audio session for recording
        setRecordingSession()
        
        // Clean up any previous player
        cleanupPlayer()
        
        audioLevels = []
        isRecording = true
        recordingTime = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.recordingTime += 0.1
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateAudioLevels()
        }
        
        setupAudioRecording()
    }
    
    private func updateAudioLevels() {
        audioRecorder?.updateMeters()
        let power = audioRecorder?.averagePower(forChannel: 0) ?? -160.0
        let linear = 1 - pow(10, power / 20)
        audioLevels.append(linear)
    }
    
    private func cleanupRecorder() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    private func cleanupPlayer() {
        audioPlayer?.stop()
        audioPlayer?.delegate = nil
        audioPlayer = nil
    }
    
    private func cleanupTimers() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        animationTimer?.invalidate()
        animationTimer = nil
        
        playerTimer?.invalidate()
        playerTimer = nil
    }
    
    func stopRecording() {
        cleanupTimers()
        cleanupRecorder()
        cleanupPlayer()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            dragOffset = .zero
        }
        
        isRecording = false
        isPlaying = false
    }
    
    func toggleRecording() {
        switch (isRecording, isPlaying) {
        case (false, false):
            startRecording()
        case (true, false):
            audioRecorder?.stop()
            // Add a small delay to ensure recording is properly stopped
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playRecording()
            }
        default:
            cancelRecording()
        }
    }
    
    func cancelRecording() {
        stopRecording()
        deleteRecordingFile()
    }
    
    private func deleteRecordingFile() {
        guard let url = recordingURL, FileManager.default.fileExists(atPath: url.path) else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    func submitRecording() {
        stopRecording()
       
    }

    // MARK: - Playback Logic
    func playRecording() {
        guard let url = recordingURL else {
            print("Recording URL is nil")
            return
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Recording file does not exist at path: \(url.path)")
            return
        }

        // Clean up previous player first
        cleanupPlayer()
        
        // Set proper audio session for playback
        setPlaybackSession()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // Ensure the player is ready before playing
            guard audioPlayer?.play() == true else {
                print("Failed to start playback")
                return
            }
            
            isPlaying = true
            isRecording = false
            startPlayerTimer()
            // awaitWaveformImage()
        } catch {
            print("Failed to play audio: \(error)")
            isPlaying = false
        }
    }
    
    private func startPlayerTimer() {
        // Clean up existing timer first
        playerTimer?.invalidate()
        
        playerTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updatePlayerTime),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func updatePlayerTime() {
        guard let player = audioPlayer else { return }
        
        let currentTime = player.currentTime
        let duration = player.duration
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        let current = formatter.string(from: currentTime) ?? "00:00"
        let total = formatter.string(from: duration) ?? "00:00"
        
        playerTime = "\(current)/\(total)"
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.playerTimer?.invalidate()
            self.playerTimer = nil
            print("Playback finished successfully: \(flag)")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.playerTimer?.invalidate()
            self.playerTimer = nil
            print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    // MARK: - Waveform Generation
    func awaitWaveformImage() {
        Task {
            await generateWaveform()
        }
    }

    func generateWaveform() async {
        guard let url = recordingURL else { return }
        
        let drawer = WaveformImageDrawer()
        let size = CGSize(width: 300, height: 120)
        
        do {
            let uiImage = try await drawer.waveformImage(
                fromAudioAt: url,
                with: .init(size: size, style: .filled(.black)),
                renderer: LinearWaveformRenderer()
            )
            
            await MainActor.run {
                waveformImage = Image(uiImage: uiImage)
            }
        } catch {
            print("Waveform generation failed: \(error)")
        }
    }

    // MARK: - Utility
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Cleanup
    deinit {
        cleanupTimers()
        cleanupRecorder()
        cleanupPlayer()
    }
}
