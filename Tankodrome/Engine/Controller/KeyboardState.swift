//
//  KeyboardState.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

final class KeyboardState {
    private(set) var isUpArrowPressed = false
    private(set) var isDownArrowPressed = false
    private(set) var isLeftArrowPressed = false
    private(set) var isRightArrowPressed = false
    private(set) var isSpacePressed = false
    private(set) var isMinusPressed = false
    private(set) var isEqualsPressed = false
    
    func update(_ data: ControlEvent.KeyData) {
        switch data.keyEquivalent {
        case .downArrow:
            isDownArrowPressed = data.isPressed
        case .upArrow:
            isUpArrowPressed = data.isPressed
        case .leftArrow:
            isLeftArrowPressed = data.isPressed
        case .rightArrow:
            isRightArrowPressed = data.isPressed
        case .space:
            isSpacePressed = data.isPressed
        case "-":
            isMinusPressed = data.isPressed
        case "+":
            isEqualsPressed = data.isPressed
        default:
            break
        }
    }
}
