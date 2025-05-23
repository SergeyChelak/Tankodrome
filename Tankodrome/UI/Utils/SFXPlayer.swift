//
//  SFXPlayer.swift
//  Tankodrome
//
//  Created by Sergey on 11.05.2025.
//

import Foundation
import AVFoundation

final class SFXPlayer {
    private let volume: Float
    private var player: AVAudioPlayer?
    
    init(volume: Float) {
        self.volume = volume
    }
    
    func play(filename: String, type: String, loops: Int = 1) throws {
        stop()
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            throw NSError()
        }
        let url = URL(fileURLWithPath: path)
        let player = try AVAudioPlayer(contentsOf: url)
        player.volume = volume
        player.numberOfLoops = loops
        player.prepareToPlay()
        player.play()
        self.player = player
    }
    
    func stop() {
        player?.stop()
    }
}
