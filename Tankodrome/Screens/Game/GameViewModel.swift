//
//  GameViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SwiftUI
import SpriteKit

class GameViewModel: ObservableObject {
    private let generator: LevelGenerator = {
        let config = levelGeneratorConfiguration()
        return LevelGenerator(configuration: config)
    }()
    private let scene = {
        let scene = GameScene()
        scene.register(
            ControllerSystem(),
            MovementSystem(),
            PhysicSystem()
        )
        return scene
    }()
    
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
                scene.setLevel(level)
            }
        } catch {
            print(error)
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
