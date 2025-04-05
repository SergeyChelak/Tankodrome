//
//  AppContext.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Combine
import Foundation

final class AppContext: ObservableObject {
    enum Flow {
        case play(GameFlow)
        case menu(MenuFlow)
    }
    private var cancellables: Set<AnyCancellable> = []

    @Published
    private(set) var flow: Flow
    
    let gameFlow: GameFlow
    let menuFlow: MenuFlow
    
    init(
        gameFlow: GameFlow,
        menuFlow: MenuFlow
    ) {
        self.menuFlow = menuFlow
        self.gameFlow = gameFlow
        self.flow = .menu(menuFlow)
        
        // subscribe
        gameFlow
            .gameSceneEventPublisher()
            .receive(on: DispatchQueue.global())
            .filter { $0 == .finish }
            .sink { [weak self] _ in
                self?.handleGameState()
            }
            .store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.flow = .play(gameFlow)
        }
    }
    
    private func handleGameState() {
        //
    }
}
