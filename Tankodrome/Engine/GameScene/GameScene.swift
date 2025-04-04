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
    private var levelRect: CGRect = .zero
    
    private var previousTime: TimeInterval?
    public private(set) var deltaTime: TimeInterval = 0.0
    
    private var systems: [System] = []
    public private(set) var sprites: [Sprite] = []
    
    private var spawnList: [Sprite] = []
    private var killList: [Sprite] = []
    
    private var mapScaleFactor: CGFloat = 1
    
    private let aggregatedControllerState = AggregatedControllerState()
    private var specialInstruction: SpecialInstruction?

    func register(_ args: System...) {
        args.forEach {
            systems.append($0)
        }
    }
    
    func setLevel(_ level: Level) {
        Task { await setLevel(level) }
    }
    
    @MainActor
    func setLevel(_ level: Level) async {
        removeAllChildren()
        self.camera = nil
        addComponents(level.sceneComponents)
        let landscape = level.landscape
        levelRect = landscape.levelRect
        addChild(landscape.tileMap)
        addChildren(level.contours)
        addChildren(level.sprites)
        setupCamera()
    }
    
    func pushControlEvent(_ event: ControlEvent) {
        if let instruction = specialInstruction(event) {
            pushSpecialInstruction(instruction)
            return
        }
        aggregatedControllerState.update(event)
    }
    
    func pushSpecialInstruction(_ instruction: SpecialInstruction) {
        self.specialInstruction = instruction
    }
    
    private func specialInstruction(_ event: ControlEvent) -> SpecialInstruction? {
        if case(.key(let keyData)) = event {
            if keyData.isPressed(.escape) {
                return .terminate
            }
        }
        return nil
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupCamera()
        physicsWorld.contactDelegate = self
    }
    
    private func setupCamera() {
        defer {
            alignCameraPosition()
        }
        self.camera = viewportCamera
        if let scale = getComponent(of: ScaleComponent.self)?.value {
            mapScaleFactor = scale
        }
        viewportCamera.setScale(mapScaleFactor)
        viewportCamera.removeFromParent()
        addChild(viewportCamera)
    }
    
    private func alignCameraPosition() {
        guard let camera,
              let position = nodes(with: PlayerMarker.self).first?.position else {
            return
        }
        var x = position.x
        x = max(x, mapScaleFactor * size.width * 0.5)
        x = min(x, levelRect.width - mapScaleFactor * size.width * 0.5)
        
        var y = position.y
        y = max(y, mapScaleFactor * size.height * 0.5)
        y = min(y, levelRect.height - mapScaleFactor * size.height * 0.5)
        let cameraPosition = CGPoint(x: x, y: y)
        camera.position = cameraPosition
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
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        for system in systems  {
            system.onPhysicsSimulated(context: self)
        }
        alignCameraPosition()
    }
    
    override func didFinishUpdate() {
        super.didFinishUpdate()
        
        addChildren(spawnList)
        spawnList.removeAll()

        killList.forEach { $0.removeFromParent() }
        killList.removeAll()
        
        [
            nodes() as [Updatable],
            viewportCamera.nodes() as [Updatable]
        ]
            .flatMap { $0 }
            .forEach {
                $0.update()
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
    var controllerState: ControllerState {
        aggregatedControllerState
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
    
    func spawn(_ sprite: Sprite) {
        spawnList.append(sprite)
    }
    
    func kill(_ sprite: Sprite) {
        killList.append(sprite)
    }
    
    func popSpecialInstruction() -> SpecialInstruction? {
        let value = self.specialInstruction
        self.specialInstruction = nil
        return value
    }
}
