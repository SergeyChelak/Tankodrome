//
//  GameScene.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    private var previousTime: TimeInterval?
    public private(set) var deltaTime: TimeInterval = 0.0
    
    private var systems: [System] = []
    public private(set) var sprites: [Sprite] = []
    
    private var spawnList: [Sprite] = []
    private var killList: [Sprite] = []
    
    private let aggregatedControllerState = AggregatedControllerState()
    private(set) var specialInstruction: SpecialInstruction?
    
    private var eventListener: SceneEventListener?
    
    func setEventListener(_ eventListener: SceneEventListener?) {
        self.eventListener = eventListener
    }

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
        aggregatedControllerState.reset()
        removeAllChildren()
        self.camera = level.camera
        addChild(level.camera)
        addComponents(level.sceneComponents)
        let landscape = level.landscape
        addChild(landscape.tileMap)
        addChildren(level.contours)
        addChildren(level.sprites)
        addChildren(level.decorations)
        systems.forEach {
            $0.levelDidSet(context: self)
        }
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
        if case(.gamepadButton(let data)) = event {
            if data.button == .menu && data.isPressed {
                return .terminate
            }
        }
        return nil
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        physicsWorld.contactDelegate = self
    }
            
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        deltaTime = currentTime - (previousTime ?? 0.0)
        guard deltaTime < 0.1 else {
            self.previousTime = currentTime
            return
        }
        sprites = nodes()
        systems.forEach {
            $0.onUpdate(context: self)
        }
        self.previousTime = currentTime
        eventListener?.onUpdate()
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        for system in systems  {
            system.onPhysicsSimulated(context: self)
        }
        eventListener?.onDidSimulatePhysics()
    }
    
    override func didFinishUpdate() {
        super.didFinishUpdate()
        
        systems.forEach {
            $0.onFinishUpdate(context: self)
        }
        
        addChildren(spawnList)
        spawnList.removeAll()

        killList.forEach { $0.removeFromParent() }
        killList.removeAll()
        

        (nodes() as [Updatable])
            .forEach {
                $0.update()
            }
        self.specialInstruction = nil
        eventListener?.onDidFinishUpdate()
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
}
