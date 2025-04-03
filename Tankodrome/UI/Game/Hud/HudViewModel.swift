//
//  HudViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import Foundation

final class HudViewModel: ObservableObject {
    private let gameFlow: GameFlow
    @Published
    private(set) var healthPercentage: CGFloat = 0.0
    
    init(gameFlow: GameFlow) {
        self.gameFlow = gameFlow
    }
    
    var healthText: String {
        String(format: "Health: %.0f%%", 100.0 * healthPercentage)
    }
    
    @MainActor
    func load() async {
        registerStateSystem()
    }

    private func registerStateSystem() {
        let stateSystem = StateSystem(receiver: self)
        gameFlow.gameScene.register(stateSystem)
    }
}

extension HudViewModel: StateReceiver {
    func setHealthPercentage(_ value: CGFloat) {
        if healthPercentage != value {
            healthPercentage = value
        }
    }
    
    func setGameState(_ gameState: GameState) {
        // TODO: handle game state updates
    }
}
