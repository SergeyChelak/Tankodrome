//
//  ViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

final class ViewFactory: AppViewFactory, GameViewFactory {
    func loadingView() -> ViewHolder {
        let view = Text("Loading")
        return ViewHolder(view)
    }
    
    func errorView(_ error: Error) -> ViewHolder {
        let view = Text(error.localizedDescription)
        return ViewHolder(view)
    }
    
    func rootView(_ context: AppContext) -> ViewHolder {
        let view = RootView(
            viewFactory: self,
            context: context
        )
        return ViewHolder(view)
    }
    
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
