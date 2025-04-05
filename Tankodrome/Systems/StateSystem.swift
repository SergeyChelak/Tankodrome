//
//  StateSystem.swift
//  Tankodrome
//
//  Created by Sergey on 27.02.2025.
//

import Foundation

final class StateSystem: System {
    private struct Stats {
        let health: CGFloat
        let maxHealth: CGFloat
        let enemies: Int
    }
    
    func levelDidSet(context: GameSceneContext) {
        updateState(context: context, newState: .play)
        
        // fill with default values
        let hudData = HudData(
            totalEnemies: 0,
            enemiesLeft: 0,
            playerHealth: 1.0
        )
        context.addComponent(HudDataComponent(value: hudData))
    }
    
    // TODO: split as two functions?
    func onUpdate(context: GameSceneContext) {
        if let instruction = context.popSpecialInstruction() {
            switch instruction {
            case .terminate:
                updateState(context: context, newState: .pause)
            case .resume:
                updateState(context: context, newState: .play)
            }
            return
        }
                
        let stats = gameStats(context: context)
        if stats.enemies == 0 || stats.health == 0.0 {
            updateState(context: context, newState: .over)
            return
        }
        
        let percentage = stats.maxHealth > 0
        ? stats.health / stats.maxHealth
        : 0
        updateHudHealth(
            context: context,
            health: percentage
        )
    }
    
    private func gameStats(context: GameSceneContext) -> Stats {
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
        
        let health = (playerHealth?.value ?? 0.0).max(0.0)
        
        return Stats(
            health: health,
            maxHealth: playerHealth?.max ?? 0.0,
            enemies: npcCount
        )
    }
    
    private func updateState(context: GameSceneContext, newState: GameState) {
        context.addComponent(GameStateComponent(value: newState))
    }
    
    private func updateHudHealth(context: GameSceneContext, health: CGFloat) {
        guard let component = context.getComponent(of: HudDataComponent.self) else {
            return
        }
        var data = component.value
        data.playerHealth = health
        component.value = data
    }
}
