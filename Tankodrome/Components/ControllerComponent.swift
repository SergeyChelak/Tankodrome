//
//  ControllerComponent.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class ControllerComponent: ValueWrapper<ControllerComponent.State>, Component {
    init() {
        super.init(value: State())
    }

    struct State {
        // tank
        var isAcceleratePressed = false
        var isDeceleratePressed = false
        var isTurnLeftPressed = false
        var isTurnRightPressed = false
        /// Analog turn command in -1...1 (positive = counterclockwise). When set it
        /// overrides the turn keys; NPC steering uses fractional values so rotation
        /// eases out and stops exactly on the desired heading instead of bang-bang
        /// oscillating around it.
        var turnThrottle: CGFloat? = nil
        // cannon
        var isShootPressed = false
    }
}
