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
    private let scene = GameScene()
    
    func scene(with size: CGSize) -> SKScene {
        scene.size = size
        return scene
    }

    func onKeyPress(_ keyPress: KeyPress) {
//        let isPressed = keyPress.phase == .down || keyPress.phase == .repeat
    }
    
    // temporary...
    func load() {
        do {
            try generator.load()
            let level = try generator.generateLevel()
            scene.addChild(level.landscape)
            scene.levelRect = CGRect(origin: .zero, size: level.size)
        } catch {
            print(error)
        }
    }
}


func levelGeneratorConfiguration() -> LevelGenerator.Configuration {
    LevelGenerator.Configuration(
        elementsFileName: "MapElements",
        elementsFileType: "json",
        tileSetName: "LandscapeTileSet"
    )
}
