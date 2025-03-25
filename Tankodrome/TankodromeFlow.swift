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
                levelComposer: services.levelComposer
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
            levelComposer: levelComposer
        )
    }
}

extension TankodromeFlow: MainMenuHandler {
    func play() {
        Task { await showGameView() }
    }
}


final class TankodromeViewFactory {
    func gameView(
        levelGenerator: LevelGenerator,
        levelComposer: LevelComposer
    ) -> ViewHolder {
        let viewModel = GameViewModel(
            levelGenerator: levelGenerator,
            levelComposer: levelComposer
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
