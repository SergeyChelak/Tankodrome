//
//  TankodromeViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

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
