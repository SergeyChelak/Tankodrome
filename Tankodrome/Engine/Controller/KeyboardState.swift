//
//  KeyboardState.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import GameController

final class KeyboardState {
    private(set) var isUpArrowPressed = false
    private(set) var isDownArrowPressed = false
    private(set) var isLeftArrowPressed = false
    private(set) var isRightArrowPressed = false
    private(set) var isSpacePressed = false
    private(set) var isEscapePressed = false
    private(set) var isWPressed = false
    private(set) var isAPressed = false
    private(set) var isSPressed = false
    private(set) var isDPressed = false
    
    func update(_ data: ControlEvent.KeyData) {
        switch data.keyCode {
        case .downArrow:
            isDownArrowPressed = data.isPressed
        case .upArrow:
            isUpArrowPressed = data.isPressed
        case .leftArrow:
            isLeftArrowPressed = data.isPressed
        case .rightArrow:
            isRightArrowPressed = data.isPressed
        case .spacebar:
            isSpacePressed = data.isPressed
        case .escape:
            isEscapePressed = data.isPressed
        case .keyW:
            isWPressed = data.isPressed
        case .keyA:
            isAPressed = data.isPressed
        case .keyS:
            isSPressed = data.isPressed
        case .keyD:
            isDPressed = data.isPressed
        default:
            break
        }
    }
}
