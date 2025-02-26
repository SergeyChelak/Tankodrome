//
//  ControllerComponent.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class ControllerComponent: Component {
    var value = State()

    struct State {
        // tank
        var isAcceleratePressed = false
        var isDeceleratePressed = false
        var isTurnLeftPressed = false
        var isTurnRightPressed = false
        // cannon
        var isShootPressed = false
    }
}
