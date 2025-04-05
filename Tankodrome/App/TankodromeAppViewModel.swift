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
            // TODO: refactor...
            let gameFlow = try composeGameFlow()
            let menuFlow = composeMenuFlow()
            let context = AppContext(
                gameFlow: gameFlow,
                menuFlow: menuFlow
            )
            await handle(context)
        } catch {
            await handleError(error)
        }
    }
    
    @MainActor
    private func handle(_ context: AppContext) async {
        self.state = .ready(context)
    }
    
    @MainActor
    private func handleError(_ error: Error) async {
        self.state = .failed(error)
    }
}
