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
            update(sprite: $0, deltaTime: deltaTime)
        }
    }
    
    private func update(sprite: Sprite, deltaTime: TimeInterval) {
        guard let controlComponent = sprite.getComponent(of: ControllerComponent.self),
              let velocityComponent = sprite.getComponent(of: VelocityComponent.self),
              let rotationSpeedComponent = sprite.getComponent(of: RotationSpeedComponent.self) else {
            return
        }
        let acceleration = sprite.getComponent(of: AccelerationComponent.self)?.value ?? 0.0
        let maxSpeed = velocityComponent.limit
        if controlComponent.value.isAcceleratePressed {
            velocityComponent.value += acceleration
            velocityComponent.value = velocityComponent.value.min(maxSpeed)
        }
        if controlComponent.value.isDeceleratePressed {
            velocityComponent.value -= acceleration
            velocityComponent.value = velocityComponent.value.max(-0.3 * maxSpeed)
        }
        
        let vector: CGVector = .rotated(radians: sprite.zRotation) * velocityComponent.value * deltaTime
        let rotation = controlComponent.turnDirection * rotationSpeedComponent.value * deltaTime
        let actions: SKAction = .group([
            .move(by: vector, duration: deltaTime),
            .rotate(byAngle: rotation, duration: deltaTime)
        ])
        sprite.run(actions)
        sprite.setAttribute(name: Tank.attributeIsAnimated, velocityComponent.value != 0.0)
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
