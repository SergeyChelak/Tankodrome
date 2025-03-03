//
//  HudModel.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import Foundation

class HudModel: ObservableObject {
    @Published
    private(set) var healthPercentage: CGFloat = 0.0
    @Published
    private(set) var state: GameState = .play
    
    let actionCallback: ActionCallback
    
    init(actionCallback: @escaping ActionCallback) {
        self.actionCallback = actionCallback
    }
    
    func reset() {
        state = .play
        healthPercentage = 0.0
    }
}

extension HudModel: HudViewModel {
    var healthText: String {
        String(format: "Health: %.0f%%", 100.0 * healthPercentage)
    }
}

extension HudModel: StateReceiver {
    func setHealthPercentage(_ value: CGFloat) {
        if healthPercentage != value {
            healthPercentage = value
        }
    }
    
    func setGameState(_ gameState: GameState) {
        if state != gameState {
            self.state = gameState
        }
    }
}
