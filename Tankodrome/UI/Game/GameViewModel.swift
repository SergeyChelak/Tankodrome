//
//  GameViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Combine
import Foundation
import SwiftUI
import SpriteKit

class GameViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    private(set) lazy var hudModel = HudModel(actionCallback: handleHudAction(_:))
        
    private let gameFlow: GameFlow
    @Published
    private(set) var opacity: CGFloat = 0.0
    
    init(
        gameFlow: GameFlow
    ) {
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
    
    @MainActor
    func load() async {
        Task { @MainActor in
            registerStateSystem()
            withAnimation {
                opacity = 1.0
            }
        }
    }
    
    private func registerStateSystem() {
        let stateSystem = StateSystem(receiver: hudModel)
        scene.register(stateSystem)
    }
    
    private func handleHudAction(_ action: HudAction) {
//        switch action {
//        case .replay:
//            replayLevel()
//        case .nextLevel:
//            nextLevel()
//        }
    }
}


extension GameViewModel: ControlHandler {
    func handleControlEvent(_ event: ControlEvent) {
        scene.pushControlEvent(event)
    }
}
