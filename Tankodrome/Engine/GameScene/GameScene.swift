//
//  GameScene.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit
import QuartzCore

class GameScene: SKScene {
    private var previousTime: TimeInterval?
    public private(set) var deltaTime: TimeInterval = 0.0
    
    private var systems: [System] = []
    public private(set) var sprites: [Sprite] = []
    
    private var spawnList: [Sprite] = []
    private var killList: [Sprite] = []
    
    private(set) var inputEvents: [ControlEvent] = []
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
        inputEvents.removeAll()
        // Drop pending spawn/kill requests of the torn-down level so they are not
        // applied to the new one on the next didFinishUpdate.
        spawnList.removeAll()
        killList.removeAll()
        removeAllChildren()
        self.camera = level.camera
        addChild(level.camera)
        addComponents(level.sceneComponents)
        let landscape = level.landscape
        addChild(landscape.tileMap)
        addChildren(level.contours)
        addChildren(level.sprites)
        addChildren(level.decorations)
        // Refresh the sprite list before notifying systems: `sprites` is otherwise
        // only rebuilt in update(), so levelDidSet would observe the previous
        // level's sprites (camera aligning to the old player, HUD counting the old
        // level's enemies) — and the stale array would keep the whole previous
        // level's node graph alive while the game sits in a menu.
        sprites = nodes()
        systems.forEach {
            $0.levelDidSet(context: self)
        }
    }
    
    func pushControlEvent(_ event: ControlEvent) {
        if let instruction = specialInstruction(event) {
            pushSpecialInstruction(instruction)
            return
        }
        inputEvents.append(event)
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
        #if DEBUG
        if GameScene.profilingEnabled {
            for system in systems {
                let start = CACurrentMediaTime()
                system.onUpdate(context: self)
                profSystemTimes[String(describing: type(of: system)), default: 0] += (CACurrentMediaTime() - start) * 1000
            }
            profileReport(deltaTime: deltaTime)
        } else {
            systems.forEach { $0.onUpdate(context: self) }
        }
        #else
        systems.forEach {
            $0.onUpdate(context: self)
        }
        #endif
        self.previousTime = currentTime
        eventListener?.onUpdate()
    }

    #if DEBUG
    // MARK: - Profiling (DEBUG only)
    /// Flip to `true` to log a per-second [PERF] breakdown of system times to the console.
    private static let profilingEnabled = false
    private var profFrames = 0
    private var profElapsed: TimeInterval = 0
    private var profSystemTimes: [String: Double] = [:]

    private func profileReport(deltaTime: TimeInterval) {
        profFrames += 1
        profElapsed += deltaTime
        guard profElapsed >= 1.0 else {
            return
        }
        let fps = Double(profFrames) / profElapsed
        let npcCount = sprites.filter { $0.hasComponent(of: NpcMarker.self) }.count
        let breakdown = profSystemTimes
            .sorted { $0.value > $1.value }
            .map { "\($0.key)=\(String(format: "%.2f", $0.value / Double(profFrames)))ms" }
            .joined(separator: " ")
        print("[PERF] fps=\(String(format: "%.1f", fps)) sprites=\(sprites.count) npc=\(npcCount) | \(breakdown)")
        profFrames = 0
        profElapsed = 0
        profSystemTimes.removeAll()
    }
    #endif
    
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
        self.inputEvents.removeAll()
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
    func nearestHit(from start: CGPoint, to end: CGPoint, excluding: Sprite?) -> Sprite? {
        var nearest: Sprite?
        var nearestDistance = CGFloat.greatestFiniteMagnitude
        physicsWorld.enumerateBodies(alongRayStart: start, end: end) { body, point, _, _ in
            guard let node = body.node as? Sprite, node !== excluding else {
                return
            }
            let distance = start.squaredDistance(to: point)
            if distance < nearestDistance {
                nearestDistance = distance
                nearest = node
            }
        }
        return nearest
    }
    
    func spawn(_ sprite: Sprite) {
        spawnList.append(sprite)
    }
    
    func kill(_ sprite: Sprite) {
        killList.append(sprite)
    }
}
