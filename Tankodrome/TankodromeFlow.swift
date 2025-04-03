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
            let gameFlow: GameFlow = try .initialize()
            gameView = factory.gameView(
                flow: gameFlow
            )
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
    
    private func nextLevel() async {
        //
    }
}

extension TankodromeFlow: MainMenuHandler {
    func play() {
        Task { await showGameView() }
    }
}

final class TankodromeViewFactory {
    func gameView(
        flow: GameFlow
    ) -> ViewHolder {
        let viewModel = GameViewModel(
            gameFlow: flow
        )
        let view = GameView(viewModel: viewModel)
        return ViewHolder(view)
    }
    
    func menuView(_ handler: MainMenuHandler) -> ViewHolder {
        ViewHolder(MainMenuView(handler: handler))
    }
}
