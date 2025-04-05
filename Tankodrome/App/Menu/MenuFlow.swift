//
//  MenuFlow.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import Foundation

protocol MenuFlowDelegate: AnyObject {
    func newGame()
    func resumeGame()
    func replayLevel()
    func closeApplication()
}

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
    
    weak var delegate: MenuFlowDelegate?
    
    init(route: Route) {
        self.route = route
    }
    
    func handle(action: Action) {
        switch action {
        case .newGame:
            delegate?.newGame()
        case .replay:
            delegate?.replayLevel()
        case .resume:
            delegate?.resumeGame()
        case .exit:
            delegate?.closeApplication()
        case .open(let route):
            open(route)
        case .empty:
            break
        }
    }
    
    private func open(_ route: Route) {
        switch route {
        case .landing:
            self.route = .landing
        case .gameOver(let gameStats):
            self.route = .gameOver(gameStats)
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
