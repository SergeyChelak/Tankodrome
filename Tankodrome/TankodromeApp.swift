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
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
    
    private func contentView() -> AnyView {
        switch flow.state {
        case .menu:
            AnyView(MainMenuView(handler: flow))
        case .game:
            AnyView(gameView)
        }
    }
}

class TankodromeAppFlow: ObservableObject {
    enum State {
        case menu, game
    }
    
    @Published
    private(set) var state: State = .menu
}

extension TankodromeAppFlow: MainMenuHandler {
    func play() {
        state = .game
    }
}
