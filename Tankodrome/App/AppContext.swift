//
//  AppContext.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

struct GameStats {
    let isWinner: Bool
}

final class AppContext: ObservableObject {
    enum Flow {
        case play(GameFlow)
        case menu(MenuFlow)
        // TODO: add flow for error state
    }
    
    private let appSettings: AppSettings
    private let audioService: AudioService
        
    @Published
    private(set) var flow: Flow
    
    private let gameFlow: GameFlow
    private let menuFlow: MenuFlow
    
    init(
        appSettings: AppSettings,
        audioService: AudioService,
        gameFlow: GameFlow,
        menuFlow: MenuFlow
    ) {
        self.appSettings = appSettings
        self.audioService = audioService
        self.menuFlow = menuFlow
        self.gameFlow = gameFlow
        self.flow = .menu(menuFlow)
        
        self.menuFlow.delegate = self
        self.gameFlow.delegate = self
    }
}

extension AppContext: GameFlowDelegate {
    func gamePaused() {
        Task { @MainActor in
            menuFlow.open(.pause)
            self.flow = .menu(menuFlow)
        }
    }
    
    func gameOver(_ stats: GameStats) {
        Task { @MainActor in
            menuFlow.open(.gameOver(stats))
            self.flow = .menu(menuFlow)
        }
    }
}

extension AppContext: MenuFlowDelegate {
    func newGame() {
        // TODO: add isBusy lock?
        Task {
            do {
                try gameFlow.nextLevel()
                Task { @MainActor in
                    self.flow = .play(gameFlow)
                }
            } catch {
                // TODO: handle error
            }
        }
    }
    
    func resumeGame() {
        gameFlow.resumeGame()
        self.flow = .play(gameFlow)
    }
    
    func replayLevel() {
        // async?
        gameFlow.replayLevel()
        self.flow = .play(gameFlow)
    }
    
    func closeApplication() {
        Darwin.exit(0)
    }
    
    func toggleSfxOption() {
        appSettings.sfxEnabled = !appSettings.sfxEnabled
    }
    
    func toggleMusicOption() {
        appSettings.musicEnabled = !appSettings.musicEnabled
    }
}
