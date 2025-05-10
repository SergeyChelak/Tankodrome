//
//  ControllerSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class ControllerSystem: System {
    func onUpdate(context: any GameSceneContext) {
        /// this function should update sprite parameters according to controller state
        /// currently the movement system is responsible for that
        /// but it makes movement system is limited to move controllable sprites only
    }
        
    func onPhysicsSimulated(context: any GameSceneContext) {
        let state = ControllerComponent.State.from(context.controllerState)
        context
            .sprites
            .compactMap { (sprite: Sprite) -> ControllerComponent? in
                guard sprite.hasComponent(of: PlayerMarker.self) else {
                    return nil
                }
                return sprite.getComponent(of: ControllerComponent.self)
            }
            .forEach {
                $0.value = state
            }
    }
}

extension ControllerComponent.State {
    static func from(_ controllerState: ControllerState) -> Self {
        var state = ControllerComponent.State()
        state.apply(controllerState.keyboardPressState)
        state.apply(controllerState.gamepadPressState)
        return state
    }
}

fileprivate extension ControllerComponent.State {
    mutating func apply(_ input: KeyboardState) {
        isAcceleratePressed |= input.isUpArrowPressed || input.isWPressed
        isDeceleratePressed |= input.isDownArrowPressed || input.isSPressed
        isTurnLeftPressed |= input.isLeftArrowPressed || input.isAPressed
        isTurnRightPressed |= input.isRightArrowPressed || input.isDPressed
        isShootPressed |= input.isSpacePressed
    }
    
    mutating func apply(_ input: GamepadState) {
        isAcceleratePressed |= input.yValue > 0
        isDeceleratePressed |= input.yValue < 0
        isTurnLeftPressed |= input.xValue < 0
        isTurnRightPressed |= input.xValue > 0
        isShootPressed |= input.isBPressed

    }
}

fileprivate extension Bool {
    static func |= (lhs: inout Bool, rhs: Bool) {
        lhs = lhs || rhs
    }
}
