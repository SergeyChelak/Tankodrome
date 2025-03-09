//
//  TankodromeApp.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI

@main
struct TankodromeApp: App {
    @StateObject
    var flow = TankodromeAppFlow()

    private let gameView = {
        let vm = GameViewModel()
        return GameView(viewModel: vm)
    }()
    
    var body: some Scene {
        WindowGroup {
            contentView()
                .task {
                    await flow.load()
                }
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
    
    private func contentView() -> AnyView {
        switch flow.state {
        case .loading(let message):
            AnyView(Text(message))
        case .menu:
            AnyView(MainMenuView(handler: flow))
        case .game:
            AnyView(gameView)
        }
    }
}

class TankodromeAppFlow: ObservableObject {
    enum State {
        case loading(String),
             menu,
             game
    }
    
    @Published
    private(set) var state: State = .loading("Loading...")
    
    func load() async {
        do {
            try await loadResources()
        } catch {
            await handleError(error)
            return
        }
        Task { @MainActor in
            state = .menu
        }
    }
    
    private func loadResources() async throws {
        let tiledDataSource = TiledDataSource()
        try tiledDataSource.load()
        let parts = tiledDataSource.maps
        print("[OK] Loaded \(parts.count) parts")
        
        let generator = LevelGenerator(configuration: levelGeneratorConfiguration())
        try generator.load(tiledDataSource)
    }
    
    @MainActor
    private func handleError(_ error: Error) async {
        state = .loading("Failed to start")
    }
}

extension TankodromeAppFlow: MainMenuHandler {
    func play() {
        state = .game
    }
}
