//
//  MenuSFXPlayer.swift
//  Tankodrome
//
//  Created by Sergey on 11.05.2025.
//

import Foundation

final class MenuSFXPlayer {
    private let service: AudioPlaybackService
    
    init(service: AudioPlaybackService) {
        self.service = service
    }
    
    func start(_ route: MenuFlow.Route) {
        switch route {
        case .landing:
            playBattleMarch()
        case .gameOver(let gameStats):
            playForGameOver(stats: gameStats)
        case .options:
            break
        case .pause:
            break
        }
    }
    
    func stop() {
        service.stopMusic()
    }
    
    private func playForGameOver(stats: GameStats) {
        if stats.isWinner {
            playBattleMarch()
        } else {
            playLose()
        }
    }
    
    private func playBattleMarch() {
        service.playMusic(
            filename: "battle_march",
            type: "wav",
            infiniteLoops: true
        )
    }
    
    private func playLose() {
        service.playMusic(
            filename: "game_over",
            type: "wav",
            infiniteLoops: false
        )
    }
}
