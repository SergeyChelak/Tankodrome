//
//  ControllerSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class ControllerSystem: System {
    func onUpdate(context: any GameSceneContext) {
        let state = ControllerComponent.State.from(context.controllerState)
        context
            .sprites
            .forEach {
                guard let component = $0.getComponent(of: ControllerComponent.self) else {
                    return
                }
                component.value = state
            }
    }
    
    func onContact(context: any GameSceneContext, collision: Collision) {
        // no op
    }
    
    func onPhysicsSimulated(context: any GameSceneContext) {
        // no op
    }
    
}

extension ControllerComponent.State {
    static func from(_ controllerState: ControllerState) -> Self {
        var state = ControllerComponent.State()
#if os(OSX)
        let input = controllerState.keyboardPressState
        state.isMoveForwardPressed = input.isUpArrowPressed
        state.isMoveBackwardPressed = input.isDownArrowPressed
        state.isTurnLeftPressed = input.isLeftArrowPressed
        state.isTurnRightPressed = input.isRightArrowPressed
        state.isShootPressed = input.isSpacePressed
#endif
#if os(iOS)
        let input = controllerState.gamepadPressState
        state.isMoveForwardPressed = input.yValue > 0
        state.isMoveBackwardPressed = input.yValue < 0
        state.isTurnLeftPressed = input.xValue < 0
        state.isTurnRightPressed = input.xValue > 0
        state.isShootPressed = input.isBPressed
#endif
        return state
    }
}
