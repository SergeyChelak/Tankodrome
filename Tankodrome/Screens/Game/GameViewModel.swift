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
    func load() async {
        do {
            try generator.load()
            let level = try generator.generateLevel()
            
            let landscape = level.landscape
            await update(landscape: landscape)
        } catch {
            print(error)
        }
    }
    
    @MainActor
    private func update(landscape: Level.Landscape) async {
        scene.addChild(landscape.tileMap)
        scene.levelRect = CGRect(origin: .zero, size: landscape.levelSize)
        
        let tank = Tank.Builder
            .random()
            .addComponent(PlayerMarker())
            .position(CGPoint(x: 1500, y: 1500))
            .build()
        scene.addChild(tank)
    }
}


func levelGeneratorConfiguration() -> LevelGenerator.Configuration {
    LevelGenerator.Configuration(
        elementsFileName: "MapElements",
        elementsFileType: "json",
        tileSetName: "LandscapeTileSet"
    )
}
