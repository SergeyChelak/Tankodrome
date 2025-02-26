//
//  PhysicSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation
import SpriteKit

final class PhysicSystem: System {
    func onContact(context: any GameSceneContext, collision: Collision) {
        let entityA = collision.firstBody
        let entityB = collision.secondBody
        guard let typeA = Body.from(entity: entityA),
              let typeB = Body.from(entity: entityB) else {
            return
        }
        switch (typeA, typeB) {
        case (.tank, .tank):
            collide(tankA: entityA, tankB: entityB)
        case (.tank, .projectile):
            collide(tank: entityA, projectile: entityB, context: context)
        case (.projectile, .tank):
            collide(tank: entityB, projectile: entityA, context: context)
        case (.tank, .obstacle):
            obstacleCollide(tank: entityA)
        case (.obstacle, .tank):
            obstacleCollide(tank: entityB)
        case (.projectile, .projectile):
            collide(projectileA: entityA, projectileB: entityB, context: context)
        case (.projectile, .obstacle):
            obstacleCollide(projectile: entityA, context: context)
        case (.obstacle, .projectile):
            obstacleCollide(projectile: entityB, context: context)
        default:
            break
        }
    }

    private func collide(tankA: Sprite, tankB: Sprite) {
        // collision of 2 tanks
        slowDownTank(tankA)
        slowDownTank(tankB)
    }
    
    private func collide(tank: Sprite, projectile: Sprite, context: GameSceneContext) {
        // collision tank with projectile
        if let component = tank.getComponent(of: HealthComponent.self),
           let damageData = projectile.getComponent(of: DamageComponent.self) {
            component.value = max(0.0, component.value - damageData.value)
            if component.value == 0.0 {
                explodeTank(tank, context: context)
            }
        }
        explodeProjectile(projectile, sceneContext: context)
    }
    
    private func obstacleCollide(tank: Sprite) {
        // collision tank with obstacle
        slowDownTank(tank)
    }
    
    private func obstacleCollide(projectile: Sprite, context: GameSceneContext) {
        // collision projectile with obstacle
        explodeProjectile(projectile, sceneContext: context)
    }
    
    private func collide(projectileA: Sprite, projectileB: Sprite, context: GameSceneContext) {
        // collision of 2 projectiles
        explodeProjectile(projectileA, sceneContext: context) {
            projectileB.removeFromParent()
        }
    }
    
    private func explodeProjectile(
        _ projectile: Sprite,
        sceneContext: GameSceneContext,
        completion: @escaping () -> Void = {}
    ) {
        if let node = explodeEmitter() {
            node.zPosition = 1000
            projectile.addChild(node)
        }
        let actions = [
            SKAction.wait(forDuration: 0.05),
            SKAction.run { sceneContext.kill(projectile) }
        ]
        projectile.run(.sequence(actions), completion: completion)
    }
    
    private func explodeTank(_ tank: Sprite, context: GameSceneContext) {
        tank.physicsBody = nil
        if let node = explodeEmitter() {
            node.zPosition = 1000
            tank.addChild(node)
        }
        let time = 0.6
        let disappearActions = [
            SKAction.wait(forDuration: time),
            SKAction.run {
                context.kill(tank)
            }
        ]
        let actions = SKAction.group([
            .sequence(disappearActions),
            .fadeOut(withDuration: time)
        ])
        tank.run(actions)
    }
    
    private func slowDownTank(_ tank: Sprite) {
        guard let component = tank.getComponent(of: VelocityComponent.self) else {
            return
        }
        component.value *= 0.5
    }
    
    private func explodeEmitter() -> SKEmitterNode? {
        SKEmitterNode(fileNamed: "Explode")
    }
    
    func onUpdate(context: any GameSceneContext) {
        // no op
    }
    
    func onPhysicsSimulated(context: any GameSceneContext) {
        // no op
    }
}

fileprivate enum Body {
    case tank, obstacle, projectile
    
    static func from(entity: Sprite) -> Body? {
        if isTank(entity) {
            return .tank
        }
        if isObstacle(entity) {
            return .obstacle
        }
        if isProjectile(entity) {
            return .projectile
        }
        return nil
    }
}

fileprivate func isTank(_ entity: Sprite) -> Bool {
    entity.hasComponent(of: PlayerMarker.self) || entity.hasComponent(of: NpcMarker.self)
}

fileprivate func isObstacle(_ entity: Sprite) -> Bool {
    entity.hasComponent(of: ObstacleMarker.self)
}

fileprivate func isProjectile(_ entity: Sprite) -> Bool {
    entity.hasComponent(of: ProjectileMarker.self)
}
