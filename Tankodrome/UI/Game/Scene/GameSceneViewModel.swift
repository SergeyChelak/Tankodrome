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

    func onAppear() {
        if inputController.setupController() {
            return
        }
#if os(iOS)
        inputController.setVirtualControllerNeeded(true)
#endif
    }
    
    func onDisappear() {
        // TODO: remove?
#if os(iOS)
        inputController.setVirtualControllerNeeded(false)
#endif
    }
}

extension GameSceneViewModel: ControlHandler {
    func handleControlEvent(_ event: ControlEvent) {
        scene.pushControlEvent(event)
    }
}
