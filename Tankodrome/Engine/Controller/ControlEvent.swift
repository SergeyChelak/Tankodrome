//
//  ControlEvent.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SwiftUI
import GameController

enum ControlEvent {
    case key(KeyData)
    case gamepadDirection(GamepadDirectionData)
    case gamepadButton(GamepadButtonState)
    
    struct KeyData {
        let isPressed: Bool
        let keyCode: GCKeyCode
    }
    
    struct GamepadButtonState {
        let button: GamepadButton
        let isPressed: Bool
    }
    
    enum GamepadButton {
        case a, b, x, y, menu
    }
    
    struct GamepadDirectionData {
        let xValue: Float
        let yValue: Float
    }
}

extension ControlEvent.KeyData {
    func isPressed(_ key: GCKeyCode) -> Bool {
        guard isPressed else {
            return false
        }
        return self.keyCode == key
    }
}
