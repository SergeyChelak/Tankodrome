//
//  MenuPages.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import Foundation

class MenuPageActionHandler {
    private let callback: MenuActionCallback
    
    init(callback: @escaping MenuActionCallback) {
        self.callback = callback
    }
    
    func handle(action: MenuFlow.Action) {
        callback(action)
    }
}

final class LandingPageDataSource: MenuPageActionHandler, MenuPageDataSource {
    let title = "Welcome"
    
    let elements = [
        MenuPageElement("New Game", .newGame),
        MenuPageElement("Options", .open(.options)),
        MenuPageElement("", .empty),
        MenuPageElement("Exit", .exit),
    ]    
}

final class GameOverPageDataSource: MenuPageActionHandler, MenuPageDataSource {
    var title: String {
        isWinner ? "You won!" : "Game Over"
    }
    
    let elements = [
        MenuPageElement("Next Level", .newGame),
        MenuPageElement("Play Again", .replay),
        MenuPageElement("", .empty),
        MenuPageElement("Exit", .exit),
    ]
    
    private let isWinner: Bool
    init(
        isWinner: Bool,
        callback: @escaping MenuActionCallback
    ) {
        self.isWinner = isWinner
        super.init(callback: callback)
    }
}

final class PausePageDataSource: MenuPageActionHandler, MenuPageDataSource {
    let title = "Pause"
    
    let elements = [
        MenuPageElement("Continue", .resume),
        MenuPageElement("Restart", .replay),
        MenuPageElement("Next Level", .newGame),
        MenuPageElement("", .empty),
        MenuPageElement("Exit", .exit),
    ]
}
