//
//  GameSceneViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation
import Combine
import SwiftUI
import SpriteKit

class GameSceneViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private let gameFlow: GameFlow
    private let inputController: InputController
    
    init(
        gameFlow: GameFlow,
        inputController: InputController
    ) {
        self.gameFlow = gameFlow
        self.inputController = inputController
        inputController.publisher
            .sink(receiveValue: handleControlEvent(_:))
            .store(in: &cancellables)
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
    
    func onAppear() {
        inputController.controllerNeeded()
    }
    
    func onDisappear() {
        inputController.controllerNotNeeded()
    }
}

extension GameSceneViewModel: ControlHandler {
    func handleControlEvent(_ event: ControlEvent) {
        scene.pushControlEvent(event)
    }
}
