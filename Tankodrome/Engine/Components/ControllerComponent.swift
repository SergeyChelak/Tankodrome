//
//  ControllerComponent.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class ControllerComponent: Component {
    var value = State()
}

extension ControllerComponent {
    struct State {
        // tank
        var isMoveForwardPressed = false
        var isMoveBackwardPressed = false
        var isTurnLeftPressed = false
        var isTurnRightPressed = false
        // cannon
        var isShootPressed = false
    }
}
