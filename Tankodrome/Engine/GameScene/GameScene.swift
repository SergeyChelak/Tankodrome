//
//  GameScene.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit

class GameScene: SKScene, GameSceneContext {
    private let viewportCamera = SKCameraNode()
    private var systems: [System] = []
    private var previousTime: TimeInterval?
    public private(set) var deltaTime: TimeInterval = 0.0
    public private(set) var sprites: [Sprite] = []
    
    func register(_ system: System) {
        systems.append(system)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
//        setupCamera()
        physicsWorld.contactDelegate = self
    }
    
    private func setupCamera() {
        self.camera = viewportCamera
//        viewportCamera.setScale(5)
        alignCameraPosition()
    }
    
    private func alignCameraPosition() {
        //
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        deltaTime = currentTime - (previousTime ?? currentTime)
        sprites = nodes()
        systems.forEach {
            $0.onUpdate(context: self)
        }
        previousTime = currentTime
    }
    
    private func nodes<T>() -> [T] {
        children
            .compactMap {
                $0 as? T
            }
    }
    
    func rayCast(from start: CGPoint, rayLength: CGFloat, angle: CGFloat) -> [Sprite] {
        let end = start + .rotated(radians: angle) * rayLength
        var nodes: [Sprite] = []
        physicsWorld.enumerateBodies(alongRayStart: start, end: end) { body, _, _, _ in
            guard let node = body.node as? Sprite else {
                return
            }
            nodes.append(node)
        }
        return nodes
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let entityA = contact.bodyA.node as? Sprite,
              let entityB = contact.bodyB.node as? Sprite else {
            return
        }
        let collision = Collision(
            firstBody: entityA,
            secondBody: entityB
        )
        systems.forEach {
            $0.onContact(context: self, collision: collision)
        }
    }
}
