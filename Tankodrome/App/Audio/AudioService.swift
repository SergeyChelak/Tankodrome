//
//  AudioService.swift
//  Tankodrome
//
//  Created by Sergey on 24.05.2025.
//

import AVFoundation
import Foundation

func composeAudioService() -> AudioService {
    AudioService(maxNodeCount: 16)
}

final class AudioService: AudioPlaybackService {
    private let maxNodeCount: Int
    private let audioEngine = AVAudioEngine()
    private let mixer = AVAudioMixerNode()
    private let bgMusicPlayer = AVAudioPlayerNode()
    
    private var preloadedBuffers: [String: AVAudioPCMBuffer] = [:]
    
    init(maxNodeCount: Int) {
        self.maxNodeCount = maxNodeCount
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
    }
 
    // TODO: perform on queue
    func preload(filename: String, type: String) -> String? {
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
        guard let key,
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
