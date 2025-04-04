//
//  GameStateComponent.swift
//  Tankodrome
//
//  Created by Sergey on 04.04.2025.
//

import Foundation

final class GameStateComponent: ValueWrapper<GameState>, Component { }

enum GameState: Equatable {
    case win, lose, play, pause
}
