//
//  GameScene.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    private let viewportCamera = SKCameraNode()
    private var systems: [System] = []
    private var previousTime: TimeInterval?
    public private(set) var deltaTime: TimeInterval = 0.0
    public private(set) var sprites: [Sprite] = []
    
    private var spawnList: [Sprite] = []
    private var killList: [Sprite] = []

    
    // TODO: make private
    var levelRect: CGRect = .zero
    
    func register(_ system: System) {
        systems.append(system)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupCamera()
        physicsWorld.contactDelegate = self
    }
    
    private func setupCamera() {
        self.camera = viewportCamera
        viewportCamera.setScale(mapScaleFactor)
        alignCameraPosition()
    }
    
    private var defaultCameraPosition: CGPoint {
        let size = levelRect.size.half()
        return CGPoint(x: size.width, y: size.height)
    }
    
    private var mapScaleFactor: CGFloat = 3
    private func alignCameraPosition() {
        let position = nodes(with: PlayerMarker.self).first?.position ?? defaultCameraPosition
        
        var x = position.x
        x = max(x, mapScaleFactor * size.width * 0.5)
        x = min(x, levelRect.width - mapScaleFactor * size.width * 0.5)
        
        var y = position.y
        y = max(y, mapScaleFactor * size.height * 0.5)
        y = min(y, levelRect.height - mapScaleFactor * size.height * 0.5)
        let cameraPosition = CGPoint(x: x, y: y)
        camera?.position = cameraPosition
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
    
    public override func didSimulatePhysics() {
        super.didSimulatePhysics()
        alignCameraPosition()
        for system in systems  {
            system.onPhysicsSimulated(context: self)
        }
        
        addChildren(spawnList)
        spawnList.removeAll()

        killList.forEach { $0.removeFromParent() }
        killList.removeAll()
    }
    
    private func nodes<T>() -> [T] {
        children
            .compactMap {
                $0 as? T
            }
    }
        
    private func nodes<T: Component>(with type: T.Type) -> [Sprite] {
        nodes()
            .filter {
                $0.hasComponent(of: type)
            }
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

extension GameScene: GameSceneContext {
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
    
    func spawn(_ sprite: Sprite) {
        spawnList.append(sprite)
    }
    
    func kill(_ sprite: Sprite) {
        killList.append(sprite)
    }
}
