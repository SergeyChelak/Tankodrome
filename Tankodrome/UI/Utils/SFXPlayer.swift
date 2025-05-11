//
//  SFXPlayer.swift
//  Tankodrome
//
//  Created by Sergey on 11.05.2025.
//

import Foundation
import AVFoundation

final class SFXPlayer {
    private var player = AVAudioPlayer()
    
    func play(filename: String, type: String, loops: Int = 1) {
        stop()
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            // TODO: handle error
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Playback error: \(error)")
            return
        }
        player.numberOfLoops = loops
        player.prepareToPlay()
        player.play()
    }
    
    func stop() {
        player.stop()
    }
}
