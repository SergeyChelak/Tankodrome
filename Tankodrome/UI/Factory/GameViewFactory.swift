//
//  GameViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

final class GameViewFactory {
    func gameView(flow: GameFlow) -> ViewHolder {
        let viewModel = GameViewModel(gameFlow: flow)
        let view = GameView(viewModel: viewModel)
        return ViewHolder(view)
    }
    
    func menuView(flow: MenuFlow) -> ViewHolder {
        let view = MenuView(flow: flow)
        return ViewHolder(view)
    }
}
