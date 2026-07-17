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

        let angularVelocity = controlComponent.turnRate * rotationSpeedComponent.value
        let velocity: CGVector = .rotated(radians: sprite.zRotation) * velocityComponent.value
        // Drive the physics body instead of teleporting the node (directly or via
        // per-frame SKActions): the solver then integrates the motion itself and
        // resolves wall/tank contacts by sliding along them, instead of the
        // penetrate-and-eject oscillation that rewriting the position causes.
        if let body = sprite.physicsBody {
            body.velocity = velocity
            body.angularVelocity = angularVelocity
        } else {
            sprite.zRotation += angularVelocity * deltaTime
            sprite.position += (velocity * deltaTime).point()
        }
    }
}

fileprivate extension ControllerComponent {
    /// Angular command in -1...1: the analog throttle when set (NPC steering),
    /// otherwise the binary turn keys (player input).
    var turnRate: CGFloat {
        if let throttle = value.turnThrottle {
            return throttle.max(-1).min(1)
        }
        if value.isTurnLeftPressed {
            return 1
        }
        if value.isTurnRightPressed {
            return -1
        }
        return 0
    }
}
