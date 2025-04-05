//
//  MenuFlow.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import Foundation

final class MenuFlow: ObservableObject {
    enum Route {
        case landing
        case gameOver(GameStats)
        case options
        case pause
    }
    
    enum Action {
        case newGame
        case replay
        case resume
        case exit
        case open(Route)
        case empty
    }
    
    struct GameStats {
        let isWinner: Bool
    }
    
    @Published
    private(set) var route: Route
    
    init(route: Route) {
        self.route = route
    }
    
    func handle(action: Action) {
        switch action {
        case .newGame:
            break
        case .replay:
            break
        case .resume:
            break
        case .exit:
            Darwin.exit(0)
        case .open(let route):
            open(route)
        case .empty:
            break
        }
        print(action)
    }
    
    private func open(_ route: Route) {
        switch route {
        case .landing:
            self.route = .landing
        case .gameOver: //(let gameStats):
            fatalError()
        case .options:
            self.route = .options
        case .pause:
            fatalError()
        }
    }
}

// TODO: return protocol
func composeMenuFlow() -> MenuFlow {
    MenuFlow(route: .landing)
}
