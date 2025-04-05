//
//  AppViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

final class AppViewFactory {
    let gameViewFactory: GameViewFactory
    
    init(gameViewFactory: GameViewFactory) {
        self.gameViewFactory = gameViewFactory
    }
    
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
            viewFactory: gameViewFactory,
            context: context
        )
        return ViewHolder(view)
    }
}
