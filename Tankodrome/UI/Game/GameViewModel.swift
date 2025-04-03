//
//  GameViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    let gameFlow: GameFlow
    @Published
    private(set) var opacity: CGFloat = 0.0
    
    init(gameFlow: GameFlow) {
        self.gameFlow = gameFlow
    }
        
    @MainActor
    func load() async {
        withAnimation {
            opacity = 1.0
        }
    }
}
