//
//  MenuSFXPlayer.swift
//  Tankodrome
//
//  Created by Sergey on 11.05.2025.
//

import Foundation

final class MenuSFXPlayer {
    private let player = SFXPlayer(volume: 0.5)
    
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
        player.stop()
    }
    
    private func playForGameOver(stats: GameStats) {
        if stats.isWinner {
            playBattleMarch()
        } else {
            playLose()
        }
    }
    
    private func playBattleMarch() {
        play(filename: "battle_march", type: "mp3", loops: -1)
    }
    
    private func playLose() {
        play(filename: "game_over", type: "mp3")
    }
    
    // TODO: temporary ignore error as this is not main feature
    private func play(filename: String, type: String, loops: Int = 1) {
        do {
            try player.play(filename: filename, type: type, loops: loops)
        } catch {
            print("[Error] menu player error: \(error)")
        }
    }
}
