//
//  GameFlow.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation
import Combine

final class GameFlow {
    private let levelGenerator: LevelGenerator
    private let levelComposer: LevelComposer
    let gameScene: GameScene
    private var levelData: LevelData
    private let eventPublisher: SceneEventPublisher
    
    init(
        levelGenerator: LevelGenerator,
        levelComposer: LevelComposer,
        gameScene: GameScene,
        levelData: LevelData,
        eventPublisher: SceneEventPublisher
    ) {
        self.levelGenerator = levelGenerator
        self.levelComposer = levelComposer
        self.gameScene = gameScene
        self.levelData = levelData
        self.eventPublisher = eventPublisher
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
    
    func gameSceneEventPublisher() -> AnyPublisher<SceneEvent, Never> {
        eventPublisher.publisher
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
    
    let scene = createGameScene()
    
    let levelData = try generator.generate()
    let level = levelComposer.level(from: levelData)
    scene.setLevel(level)
    
    let eventPublisher = BridgePublisher()
    scene.setEventListener(eventPublisher)
    
    return GameFlow(
        levelGenerator: generator,
        levelComposer: levelComposer,
        gameScene: scene,
        levelData: levelData,
        eventPublisher: eventPublisher
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
        PhysicSystem(),
        StateSystem()
    )
    return scene
}


/// Bridge from ECS to MVVM
private final class BridgePublisher {
    private let subject = PassthroughSubject<SceneEvent, Never>()
}

extension BridgePublisher: SceneEventPublisher {
    var publisher: AnyPublisher<SceneEvent, Never> {
        subject.eraseToAnyPublisher()
    }
}

extension BridgePublisher: SceneEventListener {
    func onUpdate() {
        subject.send(.update)
    }
    
    func onDidSimulatePhysics() {
        subject.send(.simulatePhysics)
    }
    
    func onDidFinishUpdate() {
        subject.send(.finish)
    }
}
