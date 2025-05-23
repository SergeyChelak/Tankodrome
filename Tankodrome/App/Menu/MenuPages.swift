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
        .options,
        .empty,
        .exit,
    ]
}

final class GameOverPageDataSource: MenuPageActionHandler, MenuPageDataSource {
    var title: String {
        isWinner ? "You won!" : "Game Over"
    }
    
    let elements = [
        MenuPageElement("Next Level", .newGame),
        MenuPageElement("Play Again", .replay),
        .empty,
        .exit,
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
        MenuPageElement("Next Level", .newGame),
        .options,
        .empty,
        .exit
    ]
}

final class OptionsPageDataSource: MenuPageActionHandler, MenuPageDataSource {
    private let settings: AppSettings
    private let parent: MenuFlow.Route?
    let title = "Options"
    
    init(
        callback: @escaping MenuActionCallback,
        parent: MenuFlow.Route?,
        settings: AppSettings
    ) {
        self.settings = settings
        self.parent = parent
        super.init(callback: callback)
    }
    
    var elements: [MenuPageElement] {
        [
            sfxOption(),
            musicOption(),
            .empty,
            MenuPageElement("Back", .open(parent ?? .landing)),
        ]
    }
    
    private func sfxOption() -> MenuPageElement {
        let title = settings.sfxEnabled ? "SFX enabled" : "SFX disabled"
        return MenuPageElement(title, .toggleSfx)
    }
    
    private func musicOption() -> MenuPageElement {
        let title = settings.musicEnabled ? "Music enabled" : "Music disabled"
        return MenuPageElement(title, .toggleMusic)
    }
}

fileprivate extension MenuPageElement {
    static let empty = MenuPageElement("", .empty)
    static let options = MenuPageElement("Options", .open(.options))
    static let exit = MenuPageElement("Exit", .exit)
}
