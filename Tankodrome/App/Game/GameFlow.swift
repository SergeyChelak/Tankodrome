//
//  GameFlow.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation
import Combine

protocol GameFlowDelegate: AnyObject {
    func gamePaused()
    
    func gameOver(_ stats: GameStats)
}

final class GameFlow {
    private var cancellables: Set<AnyCancellable> = []

    private let levelGenerator: LevelGenerator
    private let levelComposer: LevelComposer
    let gameScene: GameScene
    private var levelData: LevelData
    private let eventPublisher: SceneEventPublisher
    
    weak var delegate: GameFlowDelegate?
    private var state: GameState = .play
    
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
        
        eventPublisher
            .publisher
            .receive(on: DispatchQueue.global())
            .filter { $0 == .finish }
            .sink { [weak self] _ in
                self?.handleGameState()
            }
            .store(in: &cancellables)
    }
    
    var gameState: GameState? {
        gameScene.getComponent(of: GameStateComponent.self)?.value
    }
    
    private var isWinner: Bool {
        guard let data = gameScene.getComponent(of: HudDataComponent.self)?.value else {
            return false
        }
        return data.playerHealth > 0.0 && data.enemiesLeft == 0
    }
        
    func nextLevel() throws {
        let data = try levelGenerator.generate()
        updateLevelData(data)
    }
    
    func replayLevel() {
        updateLevelData(self.levelData)
    }
    
    private func updateLevelData(_ data: LevelData) {
        let level = levelComposer.level(from: data)
        self.levelData = data
        self.gameScene.setLevel(level)
        resumeGame()
    }
    
    func resumeGame() {
        Task { @MainActor in
            self.gameScene.isPaused = false
            self.gameScene.pushSpecialInstruction(.resume)
        }
    }
    
    func gameSceneEventPublisher() -> AnyPublisher<SceneEvent, Never> {
        eventPublisher.publisher
    }
        
    private func handleGameState() {
        guard let state = gameState, state != self.state else {
            return
        }
        self.state = state
        switch state {
        case .play:
            break
        case .pause:
            self.gameScene.isPaused = true
            delegate?.gamePaused()
        case .over:
            delegate?.gameOver(GameStats(isWinner: isWinner))
        }
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
    
    let eventPublisher = BridgePublisher()
    scene.setEventListener(eventPublisher)
    
    return GameFlow(
        levelGenerator: generator,
        levelComposer: levelComposer,
        gameScene: scene,
        levelData: .empty,
        eventPublisher: eventPublisher
    )
}


fileprivate func createGameScene() -> GameScene {
    let scene = GameScene()
    scene.register(
        CameraSystem(),
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
