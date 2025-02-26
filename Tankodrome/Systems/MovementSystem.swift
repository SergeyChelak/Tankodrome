//
//  MovementSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation
import SpriteKit

final class MovementSystem: System {
    func onUpdate(context: any GameSceneContext) {
        let deltaTime = context.deltaTime
        context.sprites.forEach {
            update(entity: $0, deltaTime: deltaTime)
        }
    }
    
    private func update(entity: Sprite, deltaTime: TimeInterval) {
        guard let controlComponent = entity.getComponent(of: ControllerComponent.self),
              let velocityComponent = entity.getComponent(of: VelocityComponent.self),
              let rotationSpeedComponent = entity.getComponent(of: RotationSpeedComponent.self) else {
            return
        }
        if controlComponent.value.isAcceleratePressed {
            velocityComponent.value += 5
        }
        if controlComponent.value.isDeceleratePressed {
            velocityComponent.value -= 5
        }
        
        let vector: CGVector = .rotated(radians: entity.zRotation) * velocityComponent.value * deltaTime
        
        let rotation = controlComponent.turnDirection * rotationSpeedComponent.value * deltaTime
        let actions: SKAction = .group([
            .move(by: vector, duration: deltaTime),
            .rotate(byAngle: rotation, duration: deltaTime)
        ])
        entity.run(actions)
    }
    
    func onContact(context: any GameSceneContext, collision: Collision) {
        //
    }
    
    func onPhysicsSimulated(context: any GameSceneContext) {
        //
    }
}

fileprivate extension ControllerComponent {
    var turnDirection: CGFloat {
        if self.value.isTurnLeftPressed {
            return 1
        }
        if self.value.isTurnRightPressed {
            return -1
        }
        return 0
    }
}
