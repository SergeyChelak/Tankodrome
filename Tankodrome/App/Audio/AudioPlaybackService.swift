//
//  AudioPlaybackService.swift
//  Tankodrome
//
//  Created by Sergey on 24.05.2025.
//

import Foundation

protocol AudioPlaybackService {
    func playSfx(filename: String, type: String)
    
    func playMusic(filename: String, type: String, infiniteLoops: Bool)
    
    func stopMusic()
}
