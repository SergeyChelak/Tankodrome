//
//  GameSceneViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation
import SwiftUI
import SpriteKit

class GameSceneViewModel: ObservableObject {
    private let gameFlow: GameFlow
    
    init(gameFlow: GameFlow) {
        self.gameFlow = gameFlow
    }
    
    private var scene: GameScene {
        gameFlow.gameScene
    }
    
    func scene(with size: CGSize) -> SKScene {
        scene.size = size
        return scene
    }

    func onKeyPress(_ keyPress: KeyPress) {
        let isPressed = keyPress.phase == .down || keyPress.phase == .repeat
        let data = ControlEvent.KeyData(
            isPressed: isPressed,
            keyEquivalent: keyPress.key
        )
        let event: ControlEvent = .key(data)
        handleControlEvent(event)
    }
}

extension GameSceneViewModel: ControlHandler {
    func handleControlEvent(_ event: ControlEvent) {
        scene.pushControlEvent(event)
    }
}
