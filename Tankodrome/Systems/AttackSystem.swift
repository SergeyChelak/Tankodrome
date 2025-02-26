//
//  AttackSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation
import SpriteKit

final class AttackSystem: System {
    func onUpdate(context: any GameSceneContext) {
        let deltaTime = context.deltaTime
        context.sprites.forEach {
            update(sprite: $0, deltaTime: deltaTime, context: context)
        }
    }
    
    private func update(sprite: Sprite, deltaTime: TimeInterval, context: GameSceneContext) {
        guard let weaponComponent = sprite.getComponent(of: WeaponComponent.self) else {
            return
        }
        weaponComponent.updateState(with: deltaTime)
        guard weaponComponent.isReady,
              let controlComponent = sprite.getComponent(of: ControllerComponent.self),
              controlComponent.value.isShootPressed else {
            return
        }
        weaponComponent.setRecharge()
        
        // setup projectile node
        let model = weaponComponent.model
        let node = Projectile.Builder()
            .addComponent(VelocityComponent(value: model.speed))
            .addComponent(ProjectileMarker())
            .addComponent(DamageComponent(value: model.damage))
            .build()
        node.zPosition = 500
        let angle = sprite.zRotation
        node.zRotation = angle
        let offset: CGVector = .rotated(radians: angle) * sprite.size.height * 0.5 * 1.5
        node.position = sprite.position + offset.point()
        let movement: SKAction = .move(by: .rotated(radians: angle), duration: 1.0 / model.speed)
        node.run(.repeatForever(movement))
        context.spawn(node)
    }
    
    func onContact(context: any GameSceneContext, collision: Collision) {
        // no op
    }
    
    func onPhysicsSimulated(context: any GameSceneContext) {
        // no op
    }
}

fileprivate extension WeaponComponent {
    var isReady: Bool {
        switch self.state {
        case .ready: true
        default: false
        }
    }
    
    func updateState(with deltaTime: TimeInterval) {
        if case .recharge(let duration) = self.state {
            setRecharge(duration - deltaTime)
        }
    }
    
    func setRecharge(_ time: TimeInterval? = nil) {
        let duration = time ?? model.rechargeTime
        state = duration > 0.0 ? .recharge(duration) : .ready
    }
}
