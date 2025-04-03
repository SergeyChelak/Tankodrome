//
//  GameFlow.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

final class GameFlow {
    private let levelGenerator: LevelGenerator
    private let levelComposer: LevelComposer
    let gameScene: GameScene
    private var levelData: LevelData
    
    init(
        levelGenerator: LevelGenerator,
        levelComposer: LevelComposer,
        gameScene: GameScene,
        levelData: LevelData
    ) {
        self.levelGenerator = levelGenerator
        self.levelComposer = levelComposer
        self.gameScene = gameScene
        self.levelData = levelData
    }
        
    func nextLevel() throws {
        let data = try levelGenerator.generate()
        updateLevelData(data)
    }
    
    func replayLevel() throws {
        updateLevelData(self.levelData)
    }
    
    func updateLevelData(_ data: LevelData) {
        let level = levelComposer.level(from: data)
        self.levelData = data
        self.gameScene.setLevel(level)
    }
}

func composeGameFlow() throws -> GameFlow {
    let tiledDataSource = TiledDataSource()
    try tiledDataSource.load()

    let tileSetMapper = TileSetMapper()
    let generator = try LevelGenerator(
        dataSource: tiledDataSource,
        tileSetMapper: tileSetMapper
    )
    
    let levelComposer = try LevelComposer(
        dataSource: tiledDataSource,
        tileSetMapper: tileSetMapper
    )
    
    let levelData = try generator.generate()
    let level = levelComposer.level(from: levelData)
    
    let scene = createGameScene()
    scene.setLevel(level)
    
    return GameFlow(
        levelGenerator: generator,
        levelComposer: levelComposer,
        gameScene: scene,
        levelData: levelData
    )
}


fileprivate func createGameScene() -> GameScene {
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
}
