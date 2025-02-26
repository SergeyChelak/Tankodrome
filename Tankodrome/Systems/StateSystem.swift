//
//  StateSystem.swift
//  Tankodrome
//
//  Created by Sergey on 27.02.2025.
//

import Combine
import Foundation

final class StateSystem: System {
    enum GameState: Equatable {
        case win, lose, play
    }

    private var state: GameState = .play {
        didSet {
            if oldValue != state {
                _statePublisher.send(state)
            }
        }
    }
    
    private var healthPercentage: CGFloat = 0.0 {
        didSet {
            if oldValue != healthPercentage {
                _healthPercentagePublisher.send(healthPercentage)
            }
        }
    }
    
    private lazy var _statePublisher: CurrentValueSubject<GameState, Never> = {
        CurrentValueSubject(self.state)
    }()
    
    var statePublisher: AnyPublisher<GameState, Never> {
        _statePublisher
            .eraseToAnyPublisher()
    }
    
    private lazy var _healthPercentagePublisher: CurrentValueSubject<CGFloat, Never> = {
        CurrentValueSubject(self.healthPercentage)
    }()
    
    var healthPercentagePublisher: AnyPublisher<CGFloat, Never> {
        _healthPercentagePublisher
            .eraseToAnyPublisher()
    }
    
    func onUpdate(context: GameSceneContext) {
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
            state = .win
            return
        }
        
        guard let playerHealth, playerHealth.value > 0.0 else {
            state = .lose
            healthPercentage = 0.0
            return
        }
        healthPercentage = playerHealth.value / playerHealth.max
    }
}
