//
//  NpcSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class NpcSystem: System {
    private let angleStep: CGFloat
    private let halfFOV: CGFloat
    private let rayLength: CGFloat
    private let squareAttackDistance: CGFloat
    
    public init(
        fieldOfView: CGFloat,
        rayLength: CGFloat,
        raysCount: Int,
        attackDistance: CGFloat
    ) {
        self.halfFOV = fieldOfView * 0.5
        self.rayLength = rayLength
        self.angleStep = fieldOfView / CGFloat(raysCount)
        self.squareAttackDistance = attackDistance.sqr()
    }
    
    func onUpdate(context: any GameSceneContext) {
        for sprite in context.sprites {
            guard sprite.hasComponent(of: NpcMarker.self) else {
                continue
            }
            let entities = detectEntities(sprite, context: context)
            updateState(npc: sprite, visibleEntities: entities)
        }
    }
    
    private func detectEntities(
        _ sprite: Sprite,
        context: GameSceneContext
    ) -> [Sprite] {
        let angle = sprite.zRotation
        return stride(
            from: angle - halfFOV,
            to: angle + halfFOV,
            by: angleStep
        )
        .compactMap {
            context.rayCast(
                from: sprite.position,
                rayLength: rayLength,
                angle: $0
            )
        }
        .flatMap { $0 }
        .unique()
    }
    
    private func updateState(npc: Sprite, visibleEntities: [Sprite]) {
        var player: Sprite?
        var obstacles: [Sprite] = []
        var borders: [Sprite] = []
        for entity in visibleEntities {
            if entity.hasComponent(of: PlayerMarker.self) {
                player = entity
                continue
            }
            if entity.hasComponent(of: BorderMarker.self) {
                borders.append(entity)
                continue
            }
            let threshold = (1.5 * max(npc.size.height, npc.size.width)).sqr()
            let squareDistance = npc.position.squaredDistance(to: entity.position)
            if squareDistance < threshold {
                obstacles.append(entity)
            }
        }
        
        guard resetControllerState(for: npc) else {
            return
        }
        if let player {
            attack(player: player, by: npc)
            return
        }
        move(for: npc, from: obstacles, borders: borders)
    }
    
    private func resetControllerState(for sprite: Sprite) -> Bool {
        guard let controllerComponent = sprite.getComponent(of: ControllerComponent.self) else {
            return false
        }
        controllerComponent.value.isAcceleratePressed = false
        controllerComponent.value.isDeceleratePressed = false
        controllerComponent.value.isShootPressed = false
        controllerComponent.value.isTurnLeftPressed = false
        controllerComponent.value.isTurnRightPressed = false
        return true
    }
    
    private func attack(player: Sprite, by entity: Sprite) {
        guard let controllerComponent = entity.getComponent(of: ControllerComponent.self),
              let velocityComponent = entity.getComponent(of: VelocityComponent.self)
              //              let shotComponent = entity.getComponent(of: ShotComponent.self)
        else {
            return
        }
        let entityAngle = entity.zRotation
        let angle = (player.position - entity.position).atan2()
        let diff = entityAngle.signedAngleDifference(angle)
        guard abs(diff) < 2e-1 else {
            if diff > 0 {
                controllerComponent.value.isTurnRightPressed = true
            } else {
                controllerComponent.value.isTurnLeftPressed = true
            }
            return
        }
        let squareDistance = player.position.squaredDistance(to: entity.position)
        if squareDistance > squareAttackDistance {
            controllerComponent.value.isAcceleratePressed = true
        } else {
            velocityComponent.value *= 0.9
        }
        controllerComponent.value.isShootPressed = true
    }
    
    private func move(for entity: Sprite, from obstacles: [Sprite], borders: [Sprite]) {
        guard let controllerComponent = entity.getComponent(of: ControllerComponent.self),
              let velocityComponent = entity.getComponent(of: VelocityComponent.self) else {
            return
        }
        let maxSpeed = velocityComponent.limit
        // check for edges
        let dist = 1.5 * entity.size.width.max(entity.size.height)
        let pos = entity.position
        for edge in borders {
            let left = pos.x - edge.position.x - edge.size.width < dist
            let right = -pos.x + edge.position.x < dist
            let bottom = pos.y - edge.position.y - edge.size.height < dist
            let top = -pos.y + edge.position.y < dist
            
            if left || right {
                controllerComponent.value.isTurnRightPressed = true
                velocityComponent.value = 0
                return
            }
            
            if top || bottom {
                controllerComponent.value.isTurnLeftPressed = true
                velocityComponent.value = 0
                return
            }
        }
        // move slowly in patrol mode
        if obstacles.isEmpty {
            velocityComponent.value = 0.2 * maxSpeed
            return
        }
        // turn to avoid obstacles
        let point = obstacles
            .map { $0.position - entity.position }
            .reduce(.zero) { acc, point in
                acc + point
            }
        let angle = .pi + point.atan2()
        let entityAngle = entity.zRotation
        let diff = entityAngle.signedAngleDifference(angle)
        if abs(diff) < 2e-1 {
            velocityComponent.value = 0.2 * maxSpeed
            return
        }
        if diff > 0 {
            controllerComponent.value.isTurnRightPressed = true
        } else {
            controllerComponent.value.isTurnLeftPressed = true
        }
    }
}
