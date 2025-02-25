//
//  AggregatedControllerState.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

final class AggregatedControllerState: ControllerState {
    private(set) var keyboardPressState = KeyboardState()
    private(set) var gamepadPressState = GamepadState()
    
    func update(_ event: ControlEvent) {
        switch event {
        case .key(let data):
            keyboardPressState.update(data)
        case .gamepadButton(let data):
            gamepadPressState.update(data)
        case .gamepadDirection(let data):
            gamepadPressState.update(data)
        }
    }
    
    func reset() {
        keyboardPressState = KeyboardState()
        gamepadPressState = GamepadState()
    }
}
