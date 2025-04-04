//
//  ControlEvent.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SwiftUI

enum ControlEvent {
    case key(KeyData)
    case gamepadDirection(GamepadDirectionData)
    case gamepadButton(GamepadButtonState)
    
    struct KeyData {
        let isPressed: Bool
        let keyEquivalent: KeyEquivalent
    }
    
    struct GamepadButtonState {
        let button: GamepadButton
        let isPressed: Bool
    }
    
    enum GamepadButton {
        case a, b, x, y
    }
    
    struct GamepadDirectionData {
        let xValue: Float
        let yValue: Float
    }
}

extension ControlEvent.KeyData {
    func isPressed(_ key: KeyEquivalent) -> Bool {
        guard isPressed else {
            return false
        }
        return self.keyEquivalent == key
    }
}
