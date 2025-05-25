//
//  AudioService.swift
//  Tankodrome
//
//  Created by Sergey on 24.05.2025.
//

import AVFoundation
import Foundation

func composeAudioService() -> AudioService {
    AudioService(
        maxNodeCount: 16,
        sfxVolume: 0.5,
        musicVolume: 0.5
    )
}

final class AudioService: AudioPlaybackService {
    typealias Volume = Float
    private let maxNodeCount: Int
    private let audioEngine = AVAudioEngine()
    private weak var mixer: AVAudioMixerNode?
    private let bgMusicPlayer = AVAudioPlayerNode()
    
    private var preloadedBuffers: [String: AVAudioPCMBuffer] = [:]
    
    private let sfxVolume: Volume
    private var isSfxEnabled: Bool = true
    private let musicVolume: Volume
    
    init(
        maxNodeCount: Int,
        sfxVolume: Volume,
        musicVolume: Volume
    ) {
        self.maxNodeCount = maxNodeCount
        self.sfxVolume = sfxVolume
        self.musicVolume = musicVolume
        let mixer = AVAudioMixerNode()
        audioEngine.attach(mixer)
        audioEngine.connect(mixer, to: audioEngine.outputNode, format: nil)
        // TODO: refactor
        // start the engine before setting up the player nodes
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("[ERROR] failed to start audio engine: \(error)")
        }
        audioEngine.attach(bgMusicPlayer)
        audioEngine.connect(bgMusicPlayer, to: mixer, format: nil)
        self.mixer = mixer
    }
    
    func setSfxEnabled(_ isEnabled: Bool) {
        self.isSfxEnabled = isEnabled
    }
    
    func setMusicEnabled(_ isEnabled: Bool) {
        bgMusicPlayer.volume = isEnabled ? musicVolume : 0.0
    }
 
    // TODO: perform on queue
    private func preload(filename: String, type: String) -> String? {
        let key = "\(filename).\(type)"
        guard let url: URL = .with(filename: filename, type: type) else {
            print("[ERROR] failed create url for key")
            return nil
        }
        if preloadedBuffers[key] != nil {
            return key
        }
        do {
            let file = try AVAudioFile(forReading: url)
            let pcmFormat = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: pcmFormat,
                frameCapacity: frameCount
            ) else {
                print("[ERROR] failed to create buffer during preloading")
                return nil
            }
            try file.read(into: buffer)
            preloadedBuffers[key] = buffer
        } catch {
            print("[ERROR] preload error: \(error)")
        }
        return key
    }
    
    private func playPreloaded(key: String?) {
        guard isSfxEnabled else {
            return
        }
        guard let mixer,
              let key,
              let buffer = preloadedBuffers[key] else {
            print("[ERROR] no preloaded data for key: \(String(describing: key))")
            return
        }
        let audioPlayer = AVAudioPlayerNode()
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: mixer, format: nil)
        
        audioPlayer.scheduleBuffer(buffer, at: nil) { [weak self] in
            guard let self else { return }
            DispatchQueue.global().async {
                audioPlayer.stop()
                self.audioEngine.detach(audioPlayer)
            }
        }
        audioPlayer.volume = sfxVolume
        audioPlayer.play()
    }
        

    func playSfx(filename: String, type: String) {
        guard audioEngine.attachedNodes.count < maxNodeCount else {
            return
        }
        
        guard let key = preload(filename: filename, type: type) else {
            print("[ERROR] no preloaded data for music file \(filename).\(type)")
            return
        }
        DispatchQueue.global().async { [weak self] in
            self?.playPreloaded(key: key)
        }
    }
        
    func playMusic(filename: String, type: String, infiniteLoops: Bool) {
        stopMusic()
        guard let key = preload(filename: filename, type: type),
              let buffer = preloadedBuffers[key] else {
            print("[ERROR] no preloaded data for music file \(filename).\(type)")
            return
        }
        bgMusicPlayer.scheduleBuffer(
            buffer,
            at: nil,
            options: infiniteLoops ? [.loops] : []
        )
        bgMusicPlayer.play()
    }
    
    func stopMusic() {
        bgMusicPlayer.stop()
    }
}

fileprivate extension URL {
    static func with(filename: String, type: String) -> URL? {
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
}
