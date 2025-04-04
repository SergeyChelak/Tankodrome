//
//  HudViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import Combine
import Foundation

final class HudViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private let gameFlow: GameFlow
    @Published
    private(set) var healthPercentage: CGFloat = 0.0
        
    init(gameFlow: GameFlow) {
        self.gameFlow = gameFlow
        gameFlow.gameSceneEventPublisher()
            .receive(on: DispatchQueue.global())
            .filter { $0 == .finish }
            .sink { [weak self] _ in
                self?.updateHud()
            }
            .store(in: &cancellables)
    }
    
    private var gameScene: GameScene {
        gameFlow.gameScene
    }
    
    func onPauseTap() {
        gameScene.pushSpecialInstruction(.terminate)
    }
    
    // function always called on background thread!
    private func updateHud() {
        // TODO: move to GameFlow?
        guard let component = gameScene.getComponent(of: HudDataComponent.self) else {
            return
        }
        let data = component.value
        if data.playerHealth != healthPercentage {
            Task { @MainActor in
                healthPercentage = data.playerHealth
            }
        }
    }
}
