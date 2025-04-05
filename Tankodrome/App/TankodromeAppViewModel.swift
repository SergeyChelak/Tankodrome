//
//  TankodromeAppViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

final class TankodromeAppViewModel: ObservableObject {
    @Published
    private(set) var state: AppState = .loading
    
    func load() async {
        do {
            let gameFlow = try composeGameFlow()
            await handle(gameFlow)
        } catch {
            await handleError(error)
        }
    }
    
    @MainActor
    private func handle(_ gameFlow: GameFlow) async {
        let context = AppContext(
            gameFlow: gameFlow,
            menuFlow: MenuFlow()
        )
        self.state = .ready(context)
    }
    
    @MainActor
    private func handleError(_ error: Error) async {
        self.state = .failed(error)
    }
}
