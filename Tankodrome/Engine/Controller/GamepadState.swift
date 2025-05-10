//
//  GamepadState.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

final class GamepadState {
    private(set) var xValue: Float = 0
    private(set) var yValue: Float = 0
    private(set) var isAPressed = false
    private(set) var isBPressed = false
    private(set) var isXPressed = false
    private(set) var isYPressed = false
    
    func update(_ data: ControlEvent.GamepadDirectionData) {
        xValue = data.xValue
        yValue = data.yValue
    }
    
    func update(_ data: ControlEvent.GamepadButtonState) {
        switch data.button {
        case .a:
            isAPressed = data.isPressed
        case .b:
            isBPressed = data.isPressed
        case .x:
            isXPressed = data.isPressed
        case .y:
            isYPressed = data.isPressed
        case .menu:
            break
        }
    }
}
