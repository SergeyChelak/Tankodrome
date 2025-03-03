//
//  GameViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Combine
import Foundation
import SwiftUI
import SpriteKit

class GameViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private let generator: LevelGenerator = {
        let config = levelGeneratorConfiguration()
        return LevelGenerator(configuration: config)
    }()
    private let scene = {
        let scene = GameScene()
        scene.register(
            ControllerSystem(),
            NpcSystem(
                fieldOfView: .pi,
                rayLength: 1500,
                raysCount: 20,
                attackDistance: 1000
            ),
            MovementSystem(),
            AttackSystem(),
            PhysicSystem()
        )
        return scene
    }()
    
    private(set) lazy var hudModel = HudModel(actionCallback: handleHudAction(_:))
    
    func scene(with size: CGSize) -> SKScene {
        scene.size = size
        return scene
    }

    func onKeyPress(_ keyPress: KeyPress) {
        let isPressed = keyPress.phase == .down || keyPress.phase == .repeat
        let data = ControlEvent.KeyData(
            isPressed: isPressed,
            keyEquivalent: keyPress.key
        )
        let event: ControlEvent = .key(data)
        handleControlEvent(event)
    }
    
    // temporary...
    func load() async {
        do {
            try generator.load()
            let level = try generator.generateLevel()
            Task { @MainActor in
                registerStateSystem()
                scene.setLevel(level)
            }
        } catch {
            print(error)
        }
    }
    
    private func registerStateSystem() {
        let stateSystem = StateSystem(receiver: hudModel)
        scene.register(stateSystem)
    }
    
    private func handleHudAction(_ action: HudAction) {
        switch action {
        case .replay:
//            hudModel.reset()
            break
        case .nextLevel:
//            hudModel.reset()
            // TODO: ...
            break
        }
    }
}


extension GameViewModel: ControlHandler {
    func handleControlEvent(_ event: ControlEvent) {
        scene.pushControlEvent(event)
    }
}


func levelGeneratorConfiguration() -> LevelGenerator.Configuration {
    LevelGenerator.Configuration(
        elementsFileName: "MapElements",
        elementsFileType: "json",
        tileSetName: "LandscapeTileSet"
    )
}
