//
//  ControllerState.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

protocol ControllerState {
    var keyboardPressState: KeyboardState { get }
    var gamepadPressState: GamepadState { get }
}
