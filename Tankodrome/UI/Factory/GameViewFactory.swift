//
//  GameViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

final class GameViewFactory {
    private let inputController: InputController
    private let menuViewFactory: MenuViewFactory
    private let audioPlaybackService: AudioPlaybackService
    
    init(
        inputController: InputController,
        menuViewFactory: MenuViewFactory,
        audioPlaybackService: AudioPlaybackService
    ) {
        self.inputController = inputController
        self.menuViewFactory = menuViewFactory
        self.audioPlaybackService = audioPlaybackService
    }
    
    func gameView(flow: GameFlow) -> ViewHolder {
        let view = GameView(
            sceneViewHolder: composeGameScene(flow),
            hudViewHolder: composeHudView(flow)
        )
        return ViewHolder(view)
    }
    
    private func composeGameScene(_ gameFlow: GameFlow) -> ViewHolder {
        let viewModel = GameSceneViewModel(
            gameFlow: gameFlow,
            inputController: inputController
        )
        let view = GameSceneView(viewModel: viewModel)
        return ViewHolder(view)
    }

    private func composeHudView(_ gameFlow: GameFlow) -> ViewHolder {
        let viewModel = HudViewModel(gameFlow: gameFlow)
        let view = HudView(viewModel: viewModel)
        return ViewHolder(view)
    }

    func menuView(flow: MenuFlow) -> ViewHolder {
        let view = MenuView(
            menuViewFactory: menuViewFactory,
            flow: flow,
            audioPlaybackService: audioPlaybackService
        )
        return ViewHolder(view)
    }
}
