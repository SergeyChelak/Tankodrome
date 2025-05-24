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
        maxSfxChannels: 16,
        sfxVolume: 0.6,
        musicVolume: 0.6
    )
}

final class AudioService: AudioPlaybackService {
    typealias Volume = Float
    
    private let sfxPlayerProcessQueue = DispatchQueue(label: "sfxPlayerProcessQueue")
    private var channels: [AVAudioPlayer]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private let sfxVolume: Volume
    private let musicVolume: Volume
    
    init(
        maxSfxChannels: Int,
        sfxVolume: Volume,
        musicVolume: Volume
    ) {
        self.sfxVolume = sfxVolume
        self.musicVolume = musicVolume
        self.channels = [AVAudioPlayer].init(
            repeating: AVAudioPlayer(),
            count: maxSfxChannels
        )
    }
    
    func setSfxEnabled(_ isEnabled: Bool) {
        let volume = isEnabled ? sfxVolume : 0.0
        sfxPlayerProcessQueue.async { [weak self] in
            self?.updateSfxVolume(volume)
        }
    }
    
    func setMusicEnabled(_ isEnabled: Bool) {
        updateMusicVolume(isEnabled ? musicVolume : 0.0)
    }
    
    private func updateSfxVolume(_ volume: Volume) {
        channels.forEach { $0.volume = volume }
    }

    private func updateMusicVolume(_ volume: Volume) {
        channels.forEach { $0.volume = volume }
    }
    
    func playSfx(filename: String, type: String) {
        guard let url: URL = .with(filename: filename, type: type) else {
            print("[ERROR] failed create url for \(filename).\(type)")
            return
        }
        sfxPlayerProcessQueue.async { [weak self] in
            guard let self else {
                return
            }
            let success = self.poolSfxPlayer(resource: url)
            if !success {
                print("[WARN] failed to pool player for \(filename).\(type)")
            }
        }
    }
    
    private func poolSfxPlayer(resource: URL) -> Bool {
        for i in 0..<channels.count {
            if channels[i].isPlaying {
                continue
            }
            do {
                channels[i] = try playerByPlaying(
                    resource: resource,
                    volume: sfxVolume,
                    loops: 1
                )
                return true
            } catch {
                print("[ERROR] failed to start sfx for \(resource) with error: \(error)")
                break
            }
        }
        return false
    }
    
    func playMusic(filename: String, type: String, infiniteLoops: Bool) {
        stopMusic()
        guard let url: URL = .with(filename: filename, type: type) else {
            print("[ERROR] failed create url for \(filename).\(type)")
            return
        }
        do {
            backgroundMusicPlayer = try playerByPlaying(
                resource: url,
                volume: musicVolume,
                loops: infiniteLoops ? -1 : 1)
        } catch {
            print("[ERROR] failed to start music for \(filename).\(type) with error: \(error)")
        }
    }
    
    func stopMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
}

fileprivate func playerByPlaying(
    resource: URL,
    volume: AudioService.Volume,
    loops: Int
) throws -> AVAudioPlayer {
    let player = try AVAudioPlayer(contentsOf: resource)
    player.volume = volume
    player.numberOfLoops = loops
    player.prepareToPlay()
    player.play()
    return player
}

fileprivate extension URL {
    static func with(filename: String, type: String) -> URL? {
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
}
