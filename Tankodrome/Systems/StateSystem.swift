//
//  StateSystem.swift
//  Tankodrome
//
//  Created by Sergey on 27.02.2025.
//

import Foundation

enum GameState: Equatable {
    case win, lose, play, pause
}

protocol StateReceiver {
    func setHealthPercentage(_ value: CGFloat)
    func setGameState(_ state: GameState)
}

final class StateSystem: System {
    private let receiver: StateReceiver
    
    init(receiver: StateReceiver) {
        self.receiver = receiver
        receiver.setGameState(.play)
        receiver.setHealthPercentage(0.0)
    }
    
    // TODO: split as two functions?
    func onUpdate(context: GameSceneContext) {
        if let instruction = context.popSpecialInstruction(),
           instruction == .terminate {
            receiver.setGameState(.pause)
            return
        }
                
        let sprites = context.sprites
        var npcCount = 0
        var playerHealth: HealthComponent?
        
        for sprite in sprites {
            if sprite.hasComponent(of: NpcMarker.self) {
                npcCount += 1
                continue
            }
            
            if sprite.hasComponent(of: PlayerMarker.self) {
                playerHealth = sprite.getComponent(of: HealthComponent.self)
                continue
            }
        }
        
        if npcCount == 0 {
            receiver.setGameState(.win)
            return
        }
        
        guard let playerHealth, playerHealth.value > 0.0 else {
            receiver.setGameState(.lose)
            receiver.setHealthPercentage(0.0)
            return
        }
        receiver.setHealthPercentage(playerHealth.value / playerHealth.max)
    }
}
