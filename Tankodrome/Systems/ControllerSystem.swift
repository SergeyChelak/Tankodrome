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
#if os(OSX)
        let input = controllerState.keyboardPressState
        state.isAcceleratePressed = input.isUpArrowPressed
        state.isDeceleratePressed = input.isDownArrowPressed
        state.isTurnLeftPressed = input.isLeftArrowPressed
        state.isTurnRightPressed = input.isRightArrowPressed
        state.isShootPressed = input.isSpacePressed
#endif
#if os(iOS)
        let input = controllerState.gamepadPressState
        state.isAcceleratePressed = input.yValue > 0
        state.isMoveBackwardPressed = input.yValue < 0
        state.isTurnLeftPressed = input.xValue < 0
        state.isTurnRightPressed = input.xValue > 0
        state.isShootPressed = input.isBPressed
#endif
        return state
    }
}
