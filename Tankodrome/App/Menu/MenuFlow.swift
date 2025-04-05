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
            break
        case .empty:
            break
        }
        print(action)
    }
}

// TODO: return protocol
func composeMenuFlow() -> MenuFlow {
    MenuFlow(route: .landing)
}
