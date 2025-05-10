//
//  GameViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

final class GameViewFactory {
    let inputController: InputController
    
    init(inputController: InputController) {
        self.inputController = inputController
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
        let view = MenuView(flow: flow)
        return ViewHolder(view)
    }
}
