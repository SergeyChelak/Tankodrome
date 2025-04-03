//
//  RootViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

enum FlowState {
    case play
    case pause
    case mainMenu
//    case gameOver(GameStats)
}

//struct GameStats {
//    let win: Bool
//}


final class RootViewModel: ObservableObject {
    @Published
    private(set) var state: FlowState = .mainMenu
    
    private let context: AppContext
    
    init(_ context: AppContext) {
        self.context = context
    }
    
    var gameFlow: GameFlow {
        context.gameFlow
    }
}

extension RootViewModel: MainMenuHandler {
    func play() {
        self.state = .play
    }
}
