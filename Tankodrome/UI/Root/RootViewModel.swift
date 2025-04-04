//
//  RootViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Combine
import Foundation

enum FlowState: Equatable {
    case play
    case pause
    case mainMenu
    case gameOver(GameStats)
}

struct GameStats: Equatable {
    let win: Bool
}


final class RootViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    @Published
    private(set) var state: FlowState = .mainMenu
    
    private let context: AppContext
    
    init(_ context: AppContext) {
        self.context = context
        context
            .gameFlow
            .gameSceneEventPublisher()
            .receive(on: DispatchQueue.global())
            .filter { $0 == .finish }
            .sink { [weak self] _ in
                self?.handleState()
            }
            .store(in: &cancellables)
    }
    
    var gameFlow: GameFlow {
        context.gameFlow
    }
    
    private func handleState() {
        guard let component = gameFlow.gameScene.getComponent(of: GameStateComponent.self) else {
            return
        }
        switch component.value {
        case .play where state != .play:
            Task {
                await switchState(.play)
            }
        case .pause where state != .pause:
            Task {
                await switchState(.pause)
            }
        case .win:
            Task {
                await switchState(.gameOver(GameStats(win: true)))
            }
        case .lose:
            Task {
                await switchState(.gameOver(GameStats(win: true)))
            }
        default:
            break
        }
    }
    
    @MainActor
    private func switchState(_ state: FlowState) async {
        self.state = state
    }
}

extension RootViewModel: MainMenuHandler {
    func play() {
        Task { await switchState(.play) }
    }
}
