//
//  TankodromeFlow.swift
//  Tankodrome
//
//  Created by Sergey on 25.03.2025.
//

import Foundation
import SwiftUI

struct GameServices {
    let levelGenerator: LevelGenerator
    let levelComposer: LevelComposer
    let gameScene: GameScene
}

final class TankodromeFlow: ObservableObject {
    private var gameView: ViewHolder = .empty
    private var menuView: ViewHolder = .empty
    
    @Published
    private(set) var activeViewHolder: ViewHolder = .empty
        
    init(factory: TankodromeViewFactory) {
        menuView = factory.menuView(self)
        Task {
            await showMenuView()
            let services = try await makeGameServices()
            gameView = factory.gameView(
                levelGenerator: services.levelGenerator,
                levelComposer: services.levelComposer,
                gameScene: services.gameScene
            )
            print("[OK] Initialized")
        }
    }
    
    @MainActor
    private func showMenuView() async {
        activeViewHolder = menuView
    }
    
    @MainActor
    private func showGameView() async {
        activeViewHolder = gameView
    }
    
    private func makeGameServices() async throws -> GameServices {
        let tiledDataSource = TiledDataSource()
        try tiledDataSource.load()
        let parts = tiledDataSource.maps
        print("[OK] Loaded \(parts.count) parts")
        
        let tileSetMapper = TileSetMapper()
        
        let generator = try LevelGenerator(
            dataSource: tiledDataSource,
            tileSetMapper: tileSetMapper
        )
        
        let levelComposer = try LevelComposer(
            dataSource: tiledDataSource,
            tileSetMapper: tileSetMapper
        )
        return GameServices(
            levelGenerator: generator,
            levelComposer: levelComposer,
            gameScene: createGameScene()
        )
    }
}

extension TankodromeFlow: MainMenuHandler {
    func play() {
        Task { await showGameView() }
    }
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

final class TankodromeViewFactory {
    func gameView(
        levelGenerator: LevelGenerator,
        levelComposer: LevelComposer,
        gameScene: GameScene
    ) -> ViewHolder {
        let viewModel = GameViewModel(
            levelGenerator: levelGenerator,
            levelComposer: levelComposer,
            gameScene: gameScene
        )
        let view = GameView(viewModel: viewModel)
        return ViewHolder(view)
    }
    
    func menuView(_ handler: MainMenuHandler) -> ViewHolder {
        ViewHolder(MainMenuView(handler: handler))
    }
    
//    func splashView() -> ViewHolder {
//        ViewHolder(Text("Loading..."))
//    }
}

class ViewHolder {
    let view: AnyView
    
    init<V: View>(_ view: V) {
        self.view = AnyView(view)
    }
    
    init(_ anyView: AnyView) {
        self.view = anyView
    }
    
    static let empty: ViewHolder = ViewHolder(EmptyView())
}
