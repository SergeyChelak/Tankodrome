//
//  StateSystem.swift
//  Tankodrome
//
//  Created by Sergey on 27.02.2025.
//

import Foundation

final class StateSystem: System {
    func levelDidSet(context: GameSceneContext) {
        updateState(context: context, newState: .play)
        
        // fill with default values
        let hudData = HudData(playerHealth: 1.0)
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
            updateState(context: context, newState: .win)
            return
        }
        
        guard let playerHealth, playerHealth.value > 0.0 else {
            updateState(context: context, newState: .lose)
            updateHudHealth(context: context, health: 0.0)
            return
        }
        updateHudHealth(context: context, health: playerHealth.value / playerHealth.max)
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
