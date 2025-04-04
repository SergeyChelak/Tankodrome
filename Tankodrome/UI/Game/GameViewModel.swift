//
//  GameViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SwiftUI

// TODO: remove as useless
class GameViewModel: ObservableObject {
    let gameFlow: GameFlow
    
    init(gameFlow: GameFlow) {
        self.gameFlow = gameFlow
    }        
}
